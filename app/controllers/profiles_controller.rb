class ProfilesController < ApplicationController
    before_filter :authenticate_user!
    after_action :verify_authorized

    before_action :set_profile, only: [:show, :edit, :update, :destroy]

    # GET /profiles
    # GET /profiles.json
    def index
        @profiles = current_user.profiles
        authorize Profile
    end

    # GET /profiles/1
    # GET /profiles/1.json
    def show
    end

    # GET /profiles/new
    def new
        authorize @profile = current_user.profiles.new
    end

    # GET /profiles/1/edit
    def edit
    end

    # POST /profiles
    # POST /profiles.json
    def create
        @profile = current_user.profiles.new(profile_params)
        authorize @profile

        respond_to do |format|
            if @profile.save
                format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
                format.json { render :show, status: :created, location: @profile }
            else
                format.html { render :new }
                format.json { render json: @profile.errors, status: :unprocessable_entity }
            end
        end
    end

    # PATCH/PUT /profiles/1
    # PATCH/PUT /profiles/1.json
    def update
        respond_to do |format|
            if @profile.update(profile_params)
                format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
                format.json { render :show, status: :ok, location: @profile }
            else
                format.html { render :edit }
                format.json { render json: @profile.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /profiles/1
    # DELETE /profiles/1.json
    def destroy
        @profile.destroy
        respond_to do |format|
            format.html { redirect_to profiles_url, notice: 'Profile was successfully destroyed.' }
            format.json { head :no_content }
        end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_profile
        @profile = current_user.profiles.find_by_id( params[:id] )

        raise ActionController::RoutingError.new( 'Profile not found.' ) if !@profile

        authorize @profile
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
        # TODO: Whitelist checks and plugins in Profi
        allowed = [
            :name, :audit_cookies, :audit_cookies_extensively, :audit_forms,
            :audit_headers, :audit_links, :authorized_by, :scope_auto_redundant_paths,
            :audit_exclude_vector_patterns, :audit_include_vector_patterns,
            :http_cookies, :http_request_headers, :scope_directory_depth_limit,
            :scope_exclude_path_patterns, :scope_exclude_path_patterns_binaries,
            :scope_exclude_path_patterns_cookies, :scope_exclude_path_patterns_vectors,
            :scope_extend_paths, :scope_include_subdomains, :audit_with_both_http_methods,
            :http_request_concurrency, :scope_include_path_patterns, :scope_page_limit,
            :login_check_pattern, :login_check_url, :spawns, :min_pages_per_instance,
            { checks: [] }, :http_proxy_host, :http_proxy_password, :http_proxy_port,
            :http_proxy_type, :http_proxy_username, :http_request_redirect_limit,
            :scope_redundant_path_patterns, :scope_restrict_paths, :http_user_agent,
            :http_request_timeout, :description, :scope_https_only,
            :scope_exclude_path_patterns_pages, :no_fingerprinting, { platforms: [] },
            :http_authentication_username, :http_authentication_password,
            :input_values, :browser_cluster_pool_size, :browser_cluster_job_timeout,
            :browser_cluster_worker_time_to_live, :browser_cluster_ignore_images,
            :browser_cluster_screen_width, :browser_cluster_screen_height,
            :scope_dom_depth_limit, :audit_link_templates
        ]

        params.require( :profile ).permit( *allowed )
    end
end
