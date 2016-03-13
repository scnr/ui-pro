module ScansHelper
    include SitesHelper

    def prepare_scan_sidebar_data
        @scan_sidebar = {
            revisions: @scan.revisions,
            data:      {}
        }

        if filter_pages?
            @scan_sidebar[:revisions] = Set.new
        end

        process_issues_after_page_filter do |issue|
            if filter_pages?
                @scan_sidebar[:revisions] << issue.revision
            end

            @scan_sidebar[:data][issue.revision_id] ||= {}
            @scan_sidebar[:data][issue.revision_id][:max_severity] ||= issue.severity.to_s

            @scan_sidebar[:data][issue.revision_id][:issue_count] ||= Set.new
            @scan_sidebar[:data][issue.revision_id][:issue_count]  << issue.digest
        end

        process_issues_done do
            @scan_sidebar[:data].each do |revision_id, data|
                @scan_sidebar[:data][revision_id][:issue_count] =
                    data[:issue_count].size
            end

            @scan_sidebar[:revisions] =
                @scan_sidebar[:revisions].sort_by { |r| r.id }.reverse
        end
    end

    def status_to_label( status )
        case status.to_sym

            when :scanning
                'primary'

            when :completed
                'success'

            when :paused, :aborted
                'warning'

            when :suspended
                'default'

            when :failed
                'danger'

            else
                'info'
        end
    end

    def scan_path( scan )
        site_scan_path( scan.site_id, scan )
    end

    def events_scan_path( scan )
        events_site_scan_path( scan.site_id, scan )
    end

end
