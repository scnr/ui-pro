module SitesHelper
    include IssuesHelper

    def prepare_site_sidebar_data
        @site_sidebar = {
            scans: @scans,
            data:  {}
        }

        if filter_pages?
            @site_sidebar[:scans] = Set.new
        end

        process_issues_after_page_filter do |issue|
            if filter_pages?
                @site_sidebar[:scans] << issue.scan
            end

            @site_sidebar[:data][issue.scan_id] ||= {}
            @site_sidebar[:data][issue.scan_id][:max_severity] ||= issue.severity.to_s

            @site_sidebar[:data][issue.scan_id][:issue_count] ||= Set.new
            @site_sidebar[:data][issue.scan_id][:issue_count]  << issue.digest
        end

        process_issues_done do
            @site_sidebar[:data].each do |scan_id, data|
                @site_sidebar[:data][scan_id][:issue_count] =
                    data[:issue_count].size
            end

            @site_sidebar[:scans] =
                @site_sidebar[:scans].sort_by { |r| r.id }.reverse
        end
    end

    def site_profile_path( profile, *args )
        edit_site_path( profile.site_id, *args )
    end

end
