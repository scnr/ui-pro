class SitesController < ApplicationController
    include SitesHelper

    before_filter :authenticate_user!

    before_action :set_site, only: [:show, :edit, :update, :destroy] +
                                       ScanResults::SCAN_RESULT_ACTIONS
    before_action :set_scans, only: ScanResults::SCAN_RESULT_ACTIONS

    include ScanResults

    # GET /sites
    # GET /sites.json
    def index
        set_sites
        @site = Site.new
    end

    def edit
    end

    # GET /sites/1
    # GET /sites/1.json
    def show
        if @site.scans.size == 0
            redirect_to new_site_scan_path( @site )
            return
        end

        redirect_to issues_site_path( @site, filter_params )
    end

    # POST /sites
    # POST /sites.json
    def create
        @site = Site.new(site_params)
        @site.user = current_user

        respond_to do |format|
            if validate_connectivity( @site ) && @site.save
                format.html { redirect_to edit_site_url(@site), notice: 'Site was successfully created.' }
                format.json { render :show, status: :created, location: @site }
            else
                set_sites

                format.html { render :index }
                format.json { render json: @site.errors, status: :unprocessable_entity }
            end
        end
    end

    # PATCH/PUT /sites/1
    # PATCH/PUT /sites/1.json
    def update
        pre = @site.profile.to_rpc_options

        respond_to do |format|
            if @site.update( site_profile_params )

                if pre != @site.profile.to_rpc_options && params[:apply] == '1'
                    @site.revisions.active.each do |revision|
                        if revision.site_profile.to_rpc_options ==
                            @site.profile.to_rpc_options
                            next
                        end

                        ScanScheduler.rescope( revision )
                    end
                end

                format.html do
                    redirect_to edit_site_url(@site),
                                notice: 'Site settings were successfully updated.'
                end
                format.json { render :show, status: :ok, location: @site }
            else
                format.html { render :edit }
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
        @sites = current_user.sites.order( id: :desc )
    end

    def set_scans
        @scans = @site.scans.includes(:schedule).includes(:user_agent).
            includes(:site_role).includes(:profile).includes(:revisions)

        prepare_site_sidebar_data
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
        params.require(:site).permit(*[ :protocol, :host, :port ])
    end

    def site_profile_params
        params.require(:site).permit(*[
            :max_parallel_scans,

            profile_attributes: [
                { platforms: [] },
                :no_fingerprinting,

                :input_values,

                :http_cookies,
                :http_request_headers,
                :http_request_concurrency,
                :http_authentication_username,
                :http_authentication_password,

                :scope_exclude_file_extensions,
                :scope_exclude_path_patterns,
                :scope_exclude_content_patterns,
                :scope_extend_paths,
                :scope_template_path_patterns,
                :scope_auto_redundant_paths,
                :scope_url_rewrites,
                :scope_https_only,

                :audit_link_templates,

                :browser_cluster_ignore_images,
                :browser_cluster_wait_for_elements
            ]
        ])

    end

    def scan_results_owner
        @site
    end

    def prepare_issue_data
        issues_summary_data(
            site:      @site,
            sitemap:   @site.sitemap_entries,
            scans:     @scans.order( id: :desc ),
            revisions: @site.revisions.order( id: :desc ),
            issues:    scan_results_issues
        )
    end

    def validate_connectivity( site )
        return true if site.protocol.blank? || site.host.blank? || site.port.blank?

        response = Arachni::HTTP::Client.get(
            "#{site.url}/favicon.ico",
            follow_location: true,
            mode:            :sync
        )

        if !response
            site.errors.add :host, "could not get response for: #{site.url}"
            return
        end

        if response.code == 0
            site.errors.add :host,
                       "#{response.return_message.to_s.downcase} for: #{site.url}"
            return
        end

        if response.headers['content-type'].start_with?( 'image' )
            IO.binwrite( site.provisioned_favicon_path, response.body )
        end

        true
    end

end
