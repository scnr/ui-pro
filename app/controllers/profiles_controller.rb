class ProfilesController < ApplicationController
    before_filter :authenticate_user!
    before_filter :prepare_plugin_params

    before_action :set_profiles,      only: [:index, :default]
    before_action :set_profile,       only: [:show, :copy, :edit, :update,
                                             :default, :destroy]
    before_action :authorize_edit,    only: [:edit, :update]
    before_action :authorize_destroy, only: [:destroy]

    PROFILE_EXPORT_PREFIX = 'Arachni Pro Profile'

    # GET /profiles
    # GET /profiles.json
    def index
    end

    # GET /profiles/1
    # GET /profiles/1.json
    def show
        set_download_header = proc do |extension|
            name = @profile.name
            [ "\n", "\r", '"' ].each { |k| name.gsub!( k, '' ) }

            headers['Content-Disposition'] =
                "attachment; filename=\"#{PROFILE_EXPORT_PREFIX} - #{name}.#{extension}\""
        end

        respond_to do |format|
            format.html # edit.html.erb
            format.js { render @profile }
            format.json do
                set_download_header.call 'json'
                render text: @profile.export( JSON )
            end
            format.yaml do
                set_download_header.call 'yaml'
                render text: @profile.export( YAML )
            end
            format.afp do
                set_download_header.call 'afp'
                render text: @profile.to_rpc_options.to_yaml
            end
        end
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

    # POST /profiles/import
    def import
        if !params[:profile] || !params[:profile][:file].is_a?( ActionDispatch::Http::UploadedFile )
            redirect_to profiles_url, alert: 'No file selected for import.'
            return
        end

        @profile = Profile.import( params[:profile][:file] )

        if !@profile
            redirect_to profiles_url, alert: 'Could not understand the Profile format.'
            return
        end

        respond_to do |format|
            format.html { render 'edit' }
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

    # PUT /profiles/1/default
    def default
        @profile.default!
        render partial: 'table', formats: :js
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

    def set_profiles
        @profiles = current_user.profiles
    end

    def authorize_edit
        return if @profile.revisions.empty?
        redirect_to @profile, error: 'Cannot edit a profile that has associated revisions.'
    end

    def authorize_destroy
        return if @profile.scans.empty?
        redirect_to @profile, error: 'Cannot delete a profile that has associated scans.'
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
        params.require( :profile ).permit( *permitted_attributes )
    end

    def permitted_attributes
        self.class.permitted_attributes
    end
    def self.permitted_attributes
        plugins_with_options = []
        plugins_with_info = ::FrameworkHelper.plugins
        plugins_with_info.each do |name, info|
            plugins_with_options << (info[:options] ?
                { name => info[:options].map( &:name ) } : name)
        end

        [
            :name,
            :description,

            { checks:    [] },
            { plugins:   plugins_with_options },

            :audit_links,
            :audit_forms,
            :audit_cookies,
            :audit_cookies_extensively,
            :audit_headers,
            :audit_jsons,
            :audit_xmls,
            :audit_parameter_names,
            :audit_with_extra_parameter,
            :audit_with_both_http_methods,
            :audit_exclude_vector_patterns,
            :audit_include_vector_patterns,

            :http_authentication_username,
            :http_authentication_password,

            :scope_page_limit,
            :scope_extend_paths,
            :scope_restrict_paths,
            :scope_include_path_patterns,
            :scope_exclude_path_patterns,
            :scope_exclude_content_patterns,
            :scope_directory_depth_limit,
            :scope_dom_depth_limit,
            :scope_exclude_binaries,

            :session_check_pattern,
            :session_check_url
        ]
    end

    def prepare_plugin_params
        return if !params[:profile]

        if params[:profile][:selected_plugins]
            selected_plugins = {}
            (params[:profile][:selected_plugins] || []).each do |plugin|
                selected_plugins[plugin] = params[:profile][:plugins][plugin]
            end

            params[:profile][:plugins] = selected_plugins
            params[:profile].delete( :selected_plugins )
        else
            params[:profile][:plugins] = {}
        end
    end

end
