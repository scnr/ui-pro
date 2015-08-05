module SitesHelper
    include IssuesHelper

    def prepare_site_issue_summary_data
        prepare_issues_summary_data(
            site:            @site,
            sitemap:         @site.sitemap_entries,
            scans:           @scans.order( id: :desc ),
            revisions:       @site.revisions.order( id: :desc ),
            issues:          @site.issues,
            reviewed_issues: @site.reviewed_issues
        )
    end

end
