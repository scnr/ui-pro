module SitesHelper
    include IssuesHelper

    def prepare_site_issue_summary_data
        @issues_summary = issues_summary_data(
            site:      @site,
            sitemap:   @site.sitemap_entries,
            scans:     @scans.order( id: :desc ),
            revisions: @site.revisions,
            issues:    @site.issues
        )
    end

end
