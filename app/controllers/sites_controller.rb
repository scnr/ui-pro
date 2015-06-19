class SitesController < ApplicationController
    include IssuesSummary

    before_filter :authenticate_user!

    before_action :set_site, only: [:show, :update, :destroy]

    # GET /sites
    # GET /sites.json
    def index
        set_sites
        @site = Site.new
    end

    # GET /sites/1
    # GET /sites/1.json
    def show
        prepare_show_data
    end

    # POST /sites
    # POST /sites.json
    def create
        @site = Site.new(site_params)
        @site.user = current_user

        respond_to do |format|
            if @site.save
                format.html { redirect_to site_url(@site), notice: 'Site was successfully created.' }
                format.json { render :show, status: :created, location: @site }
            else
                prepare_show_data
                set_sites

                format.html { render :index }
                format.json { render json: @site.errors, status: :unprocessable_entity }
            end
        end
    end

    # PATCH/PUT /sites/1
    # PATCH/PUT /sites/1.json
    def update
        respond_to do |format|
            if @site.update( site_profile_params )
                session[:active_tab] = 'settings'

                format.html do
                    redirect_to @site, notice: 'Site was successfully updated.'
                end
                format.json { render :show, status: :ok, location: @site }
            else
                prepare_show_data
                @active_tab = 'settings'

                format.html { render :show }
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
        @site = current_user.sites.find_by_id( params[:id] )

        raise ActionController::RoutingError.new( 'Site not found.' ) if !@site
    end

    def set_sites
        @sites = current_user.sites
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
        params.require(:site).permit(*[ :protocol, :host, :port ])
    end

    def site_profile_params
        params.require(:site).permit(*[profile_attributes: [
            { platforms: [] },
            :no_fingerprinting,

            :input_values,

            :http_cookies,
            :http_request_headers,
            :http_request_concurrency,
            :http_authentication_username,
            :http_authentication_password,

            :scope_redundant_path_patterns,
            :scope_auto_redundant_paths,
            :scope_url_rewrites,
            :scope_https_only,

            :audit_link_templates,

            :browser_cluster_ignore_images,
            :browser_cluster_wait_for_elements
        ]])

    end

    def prepare_show_data
        if @site.scans.empty?
            @scan = @site.scans.new
            @scan.build_schedule
            @active_tab = 'scan-form'
        else
            @scans = @site.scans
            @issues_summary = issues_summary_data(
                site:      @site,
                sitemap:   @site.sitemap_entries,
                scans:     @site.scans,
                revisions: @site.revisions,
                issues:    @site.issues
            )
            @active_tab = 'overview'
        end

        if session[:active_tab]
            @active_tab = session.delete(:active_tab)
        end
    end

end
