class ScanScheduler
module Helpers
module Scan

    # Location for storing AFR reports.
    #
    # Names will be in the format of `<Revision#id>.afr`.
    REPORT_DIR = "#{Rails.root}/reports/"

    def initialize
        super

        reset_scan_state
    end

    # Pauses the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def pause( revision )
        log_info_for revision, 'Pausing'

        instance_for( revision ).service.pause do |r|
            log_info_for revision, 'Paused'

            handle_if_rpc_error( revision, r )
        end
    end

    # Resumes the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def resume( revision )
        log_info_for revision, 'Resuming'

        instance_for( revision ).service.resume do |r|
            log_info_for revision, 'Resumed'

            handle_if_rpc_error( revision, r )
        end
    end

    # Resumes the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def restore( revision )
        log_info_for revision, 'Restoring'

        revision.scan.restoring!
        revision.update(
            started_at: Time.now,
            stopped_at: nil
        )

        spawn_instance_for( revision ) do |instance |
            instance.service.restore( revision.scan.snapshot_path ) do |r|
                log_info_for revision, 'Restoring'

                next if handle_if_rpc_error( revision, r )

                monitor( revision )
            end
        end
    end

    # Suspends the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def suspend( revision )
        log_info_for revision, 'Suspending'

        instance = instance_for( revision )

        instance.service.suspend do |r|
            log_info_for revision, 'Suspended, grabbing snapshot path.'
            handle_if_rpc_error( revision, r )
        end
    end

    # Aborts the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def abort( revision )
        log_info_for revision, 'Aborting'

        stop_monitor( revision )

        revision.scan.aborting!

        download_report_and_shutdown(
            revision,
            mark_issues_fixed: false,
            status:            'aborted'
        )
    end

    def each_due_scan( &block )
        slots = self.slots_free

        # Don't even bother...
        if slots <= 0
            log_info 'No available slots.'
            return
        end

        # Don't use #limit here to only grab the amount of scans for available
        # slots, because we may introduce a bottleneck.
        #
        # If we have a global limit of 5 and a site with a limit of 1 and
        # the site has 10 consecutive scans scheduled, then we'll be grabbing
        # the first 5 scans and just skipping them due to the site limit.
        #
        # This will block scans for other sites which could be run, until the
        # previous site's scans are performed, one at a time -- which is stupid.
        Schedule.includes( scan: :site ).due.each do |schedule|
            scan = schedule.scan
            log_info "Scan due: #{scan} (#{scan.id})"

            if slots <= 0
                log_info ' -- No available slots.'
                return
            end

            site = scan.site
            if site.max_parallel_scans <= active_instance_count_for_site( site )
                log_info ' -- Site limit has been reached.'
                next
            end

            begin
                block.call scan
            ensure
                slots -= 1
            end
        end
    end

    # Performs the scan.
    #
    # Will remove the `scan` from the {Schedule.due schedule}, create a new
    # revision, spawn an instance, start the scan and add monitoring for its
    # progress.
    #
    # @param    [Scan]  scan
    def perform( scan )
        log_info "Performing: #{scan}"

        start_at = scan.schedule.start_at

        # Remove this scan from the schedule list.
        scan.schedule.unschedule

        scan.initializing!

        revision = scan.revisions.create(
            # We don't use Time.now because it will lead to small time-slips
            # over time.
            started_at: start_at
        )

        log_info_for revision, 'Created revision.'

        spawn_instance_for( revision ) do |instance|
            instance.service.scan( scan.rpc_options ) do |response|
                next if handle_if_rpc_error( revision, response )

                monitor( revision )
            end
        end
    end

    def monitor( revision )
        reactor.at_interval TICK do |task|
            @monitors[revision.id] = task
            update( revision )
        end
    end

    def stop_monitor( revision )
        @monitors.delete( revision.id ).done
    end

    # Polls the `revision` for progress and updates its data.
    #
    # @param    [Revision]  revision
    def update( revision )
        instance = instance_for( revision )

        log_info_for revision, 'Checking progress.'

        @issue_digests_per_revision_id[revision.id] ||= revision.scan.issues.digests

        # With errors and live sitemap.
        instance.service.native_progress(
            with:    [:issues],

            # We don't care about issues logged by previous revisions at this
            # point, nor do we want issues that we've already seen.
            #
            # We will care when it's time to grab the report in order to mark
            # missing issues from previous revisions as fixed.
            without: { issues: @issue_digests_per_revision_id[revision.id] }
        ) do |progress|
            log_info_for revision, 'Got progress.'

            if progress.rpc_exception?
                handle_rpc_error( revision, progress )
                block.call true
                next
            end

            ap progress[:busy]
            ap progress[:status]
            ap progress[:statistics]

            log_debug_for revision, "Busy: #{progress[:busy]}"
            log_debug_for revision, "Status: #{progress[:status]}"

            if progress[:busy]
                log_debug_for revision, "Issues: #{progress[:issues].size}"

                progress[:issues].each do |issue|
                    @issue_digests_per_revision_id[revision.id] << issue.digest

                    create_issue( revision, issue )
                end

                revision.scan.update( status: progress[:status] )
            else
                stop_monitor( revision )

                # Special case...
                if progress[:status] == :suspended
                    instance.service.snapshot_path do |path|
                        next if handle_if_rpc_error( revision, path )

                        log_info_for revision, "Suspended, got snapshot path: #{path}"

                        revision.scan.update(
                            status:        'suspended',
                            snapshot_path: path
                        )

                        finish( revision )
                    end
                else
                    download_report_and_shutdown( revision, status: 'completed' )
                end
            end
        end
    end

    def finish( revision )
        scan = revision.scan

        revision.update( stopped_at: Time.now )

        # This one's done, schedule the next one if it's recurring.
        if !scan.suspended? && scan.recurring?
            scan.schedule_next

            log_info_for revision, 'Scheduled next occurrence for: ' +
                scan.schedule.start_at.to_s
        end

        kill_instance_for( revision )
    end

    # Aborts the scan for the `revision`, downloads and stores the report under
    # {REPORT_DIR}, updates its issues from the report and marks issues of
    # previous revisions that are not in this one as fixed.
    #
    # It will also shutdown the associated instance.
    #
    # @param    [Revision]  revision
    def download_report_and_shutdown(
        revision,
        mark_issues_fixed: true,
        status:            nil
    )
        log_info_for revision, 'Grabbing report'

        instance = instance_for( revision )
        instance.service.native_abort_and_report do |report|
            log_info_for revision, 'Got report'

            report_path = "#{REPORT_DIR}/#{revision.id}.afr"
            report.save( report_path )

            log_info_for revision, "Saved report at: #{report_path}"

            import_issues_from_report( revision, report )

            if mark_issues_fixed && revision.scan.revisions.size > 1
                mark_other_issues_fixed( revision, report.issues.map(&:digest) )
            end

            finish( revision )

            if status
                revision.scan.status = status
                revision.scan.save

                log_info_for revision, status.capitalize
            end
        end
    end

    # @private
    def reset_scan_state
        @issue_digests_per_revision_id = {}
        @monitors = {}
    end

end
end
end
