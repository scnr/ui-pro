class SitesController < ApplicationController
    before_filter :authenticate_user!
    after_action :verify_authorized

    before_action :set_site, only: [:show, :edit, :verification, :verify,
                                    :invite_user, :destroy]

    # GET /sites
    # GET /sites.json
    def index
        @sites        = current_user.sites
        @shared_sites = current_user.shared_sites

        authorize Site
    end

    # GET /sites/1
    # GET /sites/1.json
    def show
        @has_scans = false

        if @site.scans.empty?
            @scan = @site.scans.new
            authorize @scan
        else
            @scans = @site.scans
            @has_scans = true
        end
    end

    # GET /sites/new
    def new
        @site = current_user.sites.new
        authorize @site
    end

    # GET /sites/1/edit
    def edit
    end

    # PATCH/PUT /sites/1/verify
    def verify
        @site.verification.message = nil
        @site.verification.started!

        SiteVerificationWorker.perform_async(
            @site.verification.id,
            refreshable_partial_channel( [ :form_verification, @site ] )
        )

        head :ok, :content_type => 'text/html'
    end

    # GET /sites/1/verification
    def verification
    end

    # POST /sites/1/invite_user
    def invite_user
    end

    # POST /sites
    # POST /sites.json
    def create
        @site = Site.new(site_params)
        @site.user = current_user
        authorize @site

        respond_to do |format|
            if @site.save
                format.html { redirect_to verification_site_url(@site), notice: 'Site was successfully created.' }
                format.json { render :show, status: :created, location: @site }
            else
                format.html { render :new }
                format.json { render json: @site.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /sites/1
    # DELETE /sites/1.json
    def destroy
        @site.destroy
        respond_to do |format|
            format.html { redirect_to sites_url, notice: 'Site was successfully destroyed.' }
            format.json { head :no_content }
        end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_site
        @site = policy_scope(Site).find_by_id( params[:id] )

        raise ActionController::RoutingError.new( 'Site not found.' ) if !@site

        authorize @site
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
        params.require(:site).permit( *policy(@site || Site).permitted_attributes )
    end
end
