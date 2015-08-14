class RevisionsController < ApplicationController
    include IssuesHelper
    include ScansHelper

    before_filter :authenticate_user!

    before_action :set_scan
    before_action :set_revision

    include ScanResults

    # GET /revisions/1
    # GET /revisions/1.json
    def show
        redirect_to issues_site_scan_revision_path( @site, @scan, @revision, filter_params )
    end

    private

    def set_scan
        @scan = current_user.scans.joins(:revisions).find_by_id( params[:scan_id] )

        raise ActionController::RoutingError.new( 'Scan not found.' ) if !@scan

        prepare_scan_sidebar_data

        @site = @scan.site
    end

    def set_revision
        @revision = @scan.revisions.find( params[:id] )

        raise ActionController::RoutingError.new( 'Revision not found.' ) if !@revision
    end

    def scan_results_owner
        @revision
    end

    def scan_results_issues_owner
        # We can't filter issues at the revision level, that will remove a lot
        # of scan context from the rest of the interface, like from the revision
        # sidebar.
        @scan
    end

    def prepare_issue_data
        issues_summary_data(
            site:      @site,
            sitemap:   @revision.sitemap_entries,
            scans:     [@scan],
            revisions: @scan.revisions.order( id: :desc ),
            issues:    scan_results_issues
        )
    end

end
