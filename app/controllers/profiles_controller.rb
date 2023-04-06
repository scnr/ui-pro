class ProfilesController < ApplicationController
    include ProfilesControllerExportable
    include ProfilesControllerImportable
    include ControllerWithScannerOptions

    before_action :authenticate_user!

    before_action :set_profiles,      only: [:index, :default]
    before_action :set_profile,       only: [:show, :copy, :edit, :update, :default, :destroy]
    before_action :authorize_edit,    only: [:edit, :update]
    before_action :authorize_destroy, only: [:destroy]

    # GET /profiles
    # GET /profiles.json
    def index
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
        @profile = current_user.profiles.new( parsed_params )

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
            if @profile.update( parsed_params )
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
        redirect_to profiles_url
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

        @scans = @profile.scans.includes(:schedule).includes(:device).
            includes(:site_role).includes(:profile).includes(:revisions)
    end

    def parsed_params
        parsed = super

        if params[:profile][:selected_plugins]
            selected_plugins = {}
            (params[:profile][:selected_plugins] || []).each do |plugin|
                selected_plugins[plugin] = params[:profile][:plugins][plugin]
            end

            params[:profile].delete( :selected_plugins )
            parsed[:plugins] = selected_plugins
        else
            parsed[:plugins] = {}
        end

        parsed.permit( permitted_parsed_attributes )
    end

    def permitted_attributes
        attributes = super

        attributes << :name
        attributes << :description

        plugins_with_options = []
        plugins_with_info = ::FrameworkHelper.plugins
        plugins_with_info.each do |name, info|
            plugins_with_options << (info[:options] ?
                                         { name => info[:options].map( &:name ) } : name)
        end

        attributes.delete :plugins
        attributes << { plugins: plugins_with_options }

        attributes.delete :checks
        attributes << { checks: [] }

        attributes << :selected_plugins

        attributes
    end

    def set_profiles
        @profiles = current_user.profiles.order( id: :asc )
    end

    def authorize_edit
        return if @profile.revisions.empty?
        redirect_to @profile, error: 'Cannot edit a profile that has associated revisions.'
    end

    def authorize_destroy
        return if @profile.scans.empty?
        redirect_to @profile, error: 'Cannot delete a profile that has associated scans.'
    end

end
