class RevisionsController < ApplicationController
    include IssuesSummary

    before_filter :authenticate_user!
    after_action :verify_authorized

    before_action :set_scan
    before_action :set_revision, only: [:show, :destroy]

    # GET /revisions/1
    # GET /revisions/1.json
    def show
        @issues_summary = issues_summary_data(
            site:      @scan.site,
            sitemap:   @revision.sitemap_entries,
            scans:     [@revision.scan],
            revisions: [@revision],
            issues:    @revision.issues
        )
    end

    # DELETE /revisions/1
    # DELETE /revisions/1.json
    def destroy
        @revision.destroy
        respond_to do |format|
            format.html do
                redirect_to site_scan_url( @scan.site, @scan ),
                            notice: 'Revision was successfully destroyed.'
            end
            format.json { head :no_content }
        end
    end

    private

    def set_scan
        @scan = policy_scope(Scan).find_by_id( params[:scan_id] )

        raise ActionController::RoutingError.new( 'Scan not found.' ) if !@scan

        @site = @scan.site

        authorize @scan
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_revision
        authorize @revision = @scan.revisions.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def revision_params
        params.require(:revision).permit( *policy(Revision).permitted_attributes )
    end
end
