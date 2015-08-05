class RevisionsController < ApplicationController
    include IssuesHelper

    before_filter :authenticate_user!

    before_action :set_scan
    before_action :set_revision

    # GET /revisions/1
    # GET /revisions/1.json
    def show
        prepare_issues_summary_data(
            site:            @site,
            sitemap:         @revision.sitemap_entries,
            scans:           [@scan],
            revisions:       @scan.revisions.order( id: :desc ),
            issues:          @scan.issues,
            reviewed_issues: @revision.reviewed_issues,
        )
    end

    private

    def set_scan
        @scan = current_user.scans.joins(:revisions).find_by_id( params[:scan_id] )

        raise ActionController::RoutingError.new( 'Scan not found.' ) if !@scan

        @site = @scan.site
    end

    def set_revision
        @revision = @scan.revisions.find( params[:id] )

        raise ActionController::RoutingError.new( 'Revision not found.' ) if !@revision
    end
end
