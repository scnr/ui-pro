module ScansHelper
    include SitesHelper

    def prepare_scan_issue_summary_data
        @issues_summary = issues_summary_data(
            site:      @site,
            sitemap:   @scan.sitemap_entries,
            scans:     [@scan],
            revisions: @scan.revisions.order( id: :desc ),
            issues:    @scan.issues
        )
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

end
