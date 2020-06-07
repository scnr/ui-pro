class ScanScheduler
module Helpers
module Scan

    # Location for storing AFR reports.
    #
    # Names will be in the format of `<Revision#id>.afr`.
    REPORT_DIR = "#{Rails.root}/reports/"

    PERFORMANCE_SNAPSHOT_CAPTURE_INTERVAL = 1.minute

    def initialize
        super

        reset_scan_state
    end

    # Pauses the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def pause( revision )
        log_info_for revision, 'Pausing'

        instance_for( revision ).pause do |r|
            log_info_for revision, 'Paused'

            handle_if_rpc_error( revision, r )
        end
    end

    # Resumes the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def resume( revision )
        log_info_for revision, 'Resuming'

        instance_for( revision ).resume do |r|
            log_info_for revision, 'Resumed'

            handle_if_rpc_error( revision, r )
        end
    end

    # Resumes the scan for the given `revision`.
    #
    # @param    [Revision]  revision
    def restore( revision )
        log_info_for revision, 'Restoring'

        revision.restoring!
        revision.timed_out = false
        revision.save

        revision.update(
            started_at: Time.now,
            stopped_at: nil
        )

        spawn_instance_for( revision ) do |instance|
            instance.restore( revision.snapshot_path ) do |r|
                log_info_for revision, 'Restoring'

                FileUtils.rm( revision.snapshot_path )

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

        suspending revision

        instance = instance_for( revision )

        instance.suspend do |r|
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

        revision.aborting!

        download_report_and_shutdown(
            revision,
            mark_issues_fixed: false,
            status:            'aborted'
        )
    end

    def each_due_scan( &block )
        # Check for due scans first, THEN for free slots.
        # The free slots check will use a lot of CPU and we can't run it for
        # every tick.
        due = Schedule.includes( scan: :site ).due
        return if due.empty?

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
        due.each do |schedule|
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

        revision = scan.revisions.create(
            # We don't use Time.now because it will lead to small slips
            # over time.
            started_at: start_at
        )
        revision.initializing!

        log_info_for revision, 'Created revision.'

        spawn_instance_for( revision ) do |instance|
            instance.scan( revision.rpc_options ) do |response|
                next if handle_if_rpc_error( revision, response )

                monitor( revision )
            end
        end
    end

    def rescope( revision )
        scan     = revision.scan
        instance = instance_for( revision )

        log_info "Rescoping: #{scan}"

        now = Time.now
        started_at = revision.started_at

        stop_monitor( revision )
        revision.update(
            status:     'rescoped',
            stopped_at: now
        )

        instance_url = @revision_id_to_instance_url.delete( revision.id )

        # Use the previous revision's start time
        revision = scan.revisions.create(
            started_at: started_at
        )
        revision.initializing!

        log_info_for revision, 'Created revision.'

        @revision_id_to_instance_url[revision.id] = instance_url

        instance.options.set( revision.rpc_options ) do |response|
            next if handle_if_rpc_error( revision, response )

            monitor( revision )
        end
    end

    def monitor( revision )
        reactor.at_interval TICK do |task|
            @monitors[revision.id] = task
            update( revision )
        end
    end

    def stop_monitor( revision )
        return if !@monitors[revision.id]

        @monitors.delete( revision.id ).done
    end

    # Polls the `revision` for progress and updates its data.
    #
    # @param    [Revision]  revision
    def update( revision )
        instance = instance_for( revision )

        log_info_for revision, 'Checking progress.'

        # Don't grab anything but issues marked as fixed, this way we'll be
        # able to auto-review them ASAP and let the user know of regressions.
        progress_tracking_for( revision )[:issue_digests] ||=
            revision.scan.issues.where.not( state: 'fixed' ).digests

        # With errors and live sitemap.
        instance.native_progress(
            with:    {
                issues:  true,
                sitemap: progress_tracking_for( revision )[:coverage_entries].size,
                errors:  progress_tracking_for( revision )[:error_lines]
            },

            # We don't care about issues logged by previous revisions at this
            # point, nor do we want issues that we've already seen.
            #
            # We will care when it's time to grab the report in order to mark
            # missing issues from previous revisions as fixed.
            without: { issues: progress_tracking_for( revision )[:issue_digests] },
        ) do |progress|
            handle_progress( revision, progress )
        end
    end

    def handle_progress( revision, progress )
        log_info_for revision, 'Got progress.'

        if progress.rpc_exception?
            handle_rpc_error( revision, progress )
            return
        end

        # ap progress
        # ap progress[:busy]
        # ap progress[:status]
        # ap progress[:statistics]
        # ap progress[:messages]
        # ap progress[:sitemap]

        log_debug_for revision, "Busy:   #{progress[:busy]}"
        log_debug_for revision, "Status: #{progress[:status]}"

        if !revision.seed
            revision.update( seed: progress[:seed] )
        end

        if progress[:busy]
            handle_progress_active( revision, progress )
        else
            handle_progress_inactive( revision, progress )
        end
    end

    def handle_progress_active( revision, progress )
        schedule   = revision.scan.schedule
        statistics = progress[:statistics]
        runtime    = statistics[:runtime]

        if !suspending?( revision ) && schedule.stop_after_hours &&
            schedule.stop_after_hours.hours < runtime.seconds

            log_debug_for revision, 'Timeout reached.'
            ap 'TIMEOUT'

            revision.timed_out = true
            revision.save

            if schedule.stop_suspend
                suspend revision
            else
                abort revision
            end

            return
        end

        log_debug_for revision, "Issues: #{progress[:issues].size}"

        progress_tracking_for( revision )[:issue_digests] ||= []
        progress[:issues].each do |issue|
            progress_tracking_for( revision )[:issue_digests] << issue.digest

            create_issue( revision, issue )
        end

        add_coverage_entries( revision, progress[:sitemap] )

        capture_performance_snapshot( revision, statistics )

        progress_tracking_for( revision )[:error_lines] += progress[:errors].size

        update = {}
        if revision.status != progress[:status].to_s
            update[:status] = progress[:status]
        end

        # Add a newline at the end if we have any errors.
        if progress[:errors].any?
            update[:error_messages] = "#{revision.error_messages}#{progress[:errors].join( "\n" )}\n"
        end

        return if update.empty?

        revision.update( update )
    end

    def handle_progress_inactive( revision, progress )
        instance = instance_for( revision )

        stop_monitor( revision )

        if progress[:errors].any?
            revision.error_messages = "#{revision.error_messages}#{progress[:errors].join( "\n" )}\n"
        end

        # Special case...
        if progress[:status] == :suspended
            instance.snapshot_path do |path|
                next if handle_if_rpc_error( revision, path )

                log_info_for revision, "Suspended, got snapshot path: #{path}"

                revision.update(
                    status:        'suspended',
                    snapshot_path: path
                )

                finish( revision )
            end
        else
            download_report_and_shutdown(
                revision,
                # Don't mark issues as fixed if they're missing from a rescoped
                # scan, issues may be missing due to the scope reduction.
                mark_issues_fixed: revision.index == 1 || !revision.previous.rescoped?,
                status:            'completed'
            )
        end
    end

    def finish( revision )
        done_suspending( revision )
        @progress_tracker.delete revision.id

        scan = revision.scan

        revision.update( stopped_at: Time.now )

        # This one's done, schedule the next one if it's recurring.
        if !revision.suspended? && scan.recurring?
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
        instance.native_abort_and_report do |report|
            log_info_for revision, 'Got report'

            report_path = "#{REPORT_DIR}/#{revision.id}.ser"
            report.save( report_path )

            log_info_for revision, "Saved report at: #{report_path}"

            import_issues_from_report( revision, report )
            import_coverage_from_report( revision, report )

            if mark_issues_fixed && revision.scan.revisions.size > 1
                mark_other_issues_fixed( revision, report.issues.map(&:digest) )
            end

            finish( revision )

            if status && revision.status != status
                revision.status = status
                revision.save

                log_info_for revision, status.capitalize
            end
        end
    end

    def import_coverage_from_report( revision, report )
        add_coverage_entries( revision, report.sitemap )
    end

    def add_coverage_entries( revision, sitemap )
        sitemap.each do |url, code|
            add_coverage_entry( revision, url, code )
        end
    end

    def add_coverage_entry( revision, url, code )
        return if progress_tracking_for( revision )[:coverage_entries].include?( url )
        progress_tracking_for( revision )[:coverage_entries] << url

        entry = revision.sitemap_entries.find_or_initialize_by( url: url )
        entry.update( coverage: true, code: code ) if !entry.coverage
    end

    def done_suspending( revision )
        @suspending.delete revision.id
    end

    def suspending( revision )
        @suspending << revision.id
    end

    def suspending?( revision )
        @suspending.include?( revision.id )
    end

    def capture_performance_snapshot( revision, statistics )
        progress_tracking_for( revision )[:last_performance_update] ||=
            PERFORMANCE_SNAPSHOT_CAPTURE_INTERVAL.ago

        attributes = PerformanceSnapshot.engine_to_attributes( statistics )

        revision.performance_snapshot.update( attributes )

        return if Time.now - progress_tracking_for( revision )[:last_performance_update] <
                    PERFORMANCE_SNAPSHOT_CAPTURE_INTERVAL

        revision.performance_snapshots.create( attributes )

        progress_tracking_for( revision )[:last_performance_update] = Time.now
    end

    def progress_tracking_for( revision )
        @progress_tracker[revision.id] ||= {
            issue_digests:    nil,
            coverage_entries: [],
            sitemap:          ::Set.new,
            error_lines:      0
        }
    end

    # @private
    def reset_scan_state
        @progress_tracker = {}
        @monitors         = {}
        @suspending       = Set.new
    end

end
end
end
