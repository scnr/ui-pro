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

    # Suspends the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def suspend( revision )
        log_info_for revision, 'Suspending'

        instance = instance_for( revision )

        instance.service.suspend do |r|
            handle_if_rpc_error( revision, r )

            log_info_for revision, 'Suspended, grabbing snapshot path.'

            instance.service.snapshot_path do |path|
                handle_if_rpc_error( revision, path )

                log_info_for revision, "Suspended, got snapshot path: #{path}"

                revision.scan.snapshot_path = path
                revision.scan.save
            end
        end
    end

    # Aborts the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def abort( revision )
        log_info_for revision, 'Aborting'

        download_report_and_shutdown( revision )
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

        if scan.schedule.recurring?
            # Remove this scan from the schedule list.
            scan.schedule.unschedule
        else
            # Completely remove scheduling for this scan, it was an one-off.
            scan.schedule.destroy
            scan.save
        end

        revision = scan.revisions.create(
            state:      'initializing',
            started_at: Time.now
        )

        log_info_for revision, 'Created revision.'

        spawn_instance_for( revision ) do |instance|
            instance.service.scan( scan.rpc_options ) do |response|
                if response.rpc_exception?
                    next handle_rpc_error( revision, response )
                end

                reactor.at_interval TICK do |task|
                    update( revision ) do |done|
                        next if !done

                        task.done
                    end
                end
            end
        end
    end

    # Polls the `revision` for progress and updates its data.
    #
    # @param    [Revision]  revision
    def update( revision, &block )
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

            ap progress[:statistics]

            log_debug_for revision, "Busy: #{progress[:busy]}"
            log_debug_for revision, "Status: #{progress[:status]}"

            if progress[:busy]
                log_debug_for revision, "Issues: #{progress[:issues].size}"

                progress[:issues].each do |issue|
                    @issue_digests_per_revision_id[revision.id] << issue.digest

                    create_issue( revision, issue )
                end

                revision.update( state: progress[:status] )
            else
                download_report_and_shutdown( revision )

                revision.update(
                    state:      nil,
                    stopped_at: Time.now
                )

                # This one's done, schedule the next one if it's recurring.
                if revision.scan.schedule.recurring?
                    revision.scan.schedule.schedule_next
                    log_info_for revision, 'Scheduled next occurrence for: ' +
                        revision.scan.schedule.start_at.to_s
                end
            end

            block.call !progress[:busy]
        end
    end

    # Aborts the scan for the `revision`, downloads and stores the report under
    # {REPORT_DIR}, updates its issues from the report and marks issues of
    # previous revisions that are not in this one as fixed.
    #
    # It will also shutdown the associated instance.
    #
    # @param    [Revision]  revision
    def download_report_and_shutdown( revision )
        log_info_for revision, 'Grabbing report'

        instance = instance_for( revision )
        instance.service.native_abort_and_report do |report|
            log_info_for revision, 'Got report'

            report_path = "#{REPORT_DIR}/#{revision.id}.afr"
            report.save( report_path )

            log_info_for revision, "Saved report at: #{report_path}"

            import_issues_from_report( revision, report )

            mark_other_issues_fixed( revision, report.issues.map(&:digest) )

            kill_instance_for( revision )
        end
    end

    # @private
    def reset_scan_state
        @issue_digests_per_revision_id = {}
    end

end
end
end
