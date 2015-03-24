class ProfilesController < ApplicationController
    before_filter :authenticate_user!
    before_action :set_profile, only: [:show, :copy, :edit, :update, :destroy]

    # GET /profiles
    # GET /profiles.json
    def index
        @profiles = current_user.profiles
    end

    # GET /profiles/1
    # GET /profiles/1.json
    def show
    end

    # GET /profiles/new
    def new
        @profile = current_user.profiles.new
    end

    # GET /profiles/1/edit
    def edit
    end

    # GET /profiles/1/copy
    def copy
        @profile = @profile.dup
        render :new
    end

    # POST /profiles
    # POST /profiles.json
    def create
        @profile = current_user.profiles.new(profile_params)

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
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
        params.require( :profile ).permit( *permitted_attributes )
    end

    def permitted_attributes
        [
            :name,
            :description,
            { checks:    [] },
            { platforms: [] },
            :no_fingerprinting,
            :input_values,
            :audit_links,
            :audit_forms,
            :audit_cookies,
            :audit_headers,
            :audit_link_templates,
            :audit_with_both_http_methods,
            :audit_exclude_vector_patterns,
            :audit_include_vector_patterns,
            :http_user_agent,
            :http_cookies,
            :http_request_headers,
            :scope_page_limit,
            :scope_extend_paths,
            :scope_restrict_paths,
            :scope_include_path_patterns,
            :scope_exclude_path_patterns,
            :scope_redundant_path_patterns,
            :scope_exclude_content_patterns,
            :scope_exclude_vector_patterns,
            :scope_include_vector_patterns,
            :scope_include_subdomains,
            :scope_url_rewrites,
            :session_check_pattern,
            :session_check_url,
            :http_authentication_username,
            :http_authentication_password,
            :browser_cluster_screen_width,
            :browser_cluster_screen_height
        ]
    end

end
