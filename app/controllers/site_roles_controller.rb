class SiteRolesController < ApplicationController
    include ControllerWithScannerOptions

    before_action :authenticate_user!

    before_action :set_site
    before_action :set_site_roles, only: [:index, :destroy]
    before_action :set_site_role,  only: [:show, :edit, :update, :destroy]

    respond_to :html, :js

    def index
    end

    def show
        respond_with(@site, @site_role)
    end

    def new
        @site_role = SiteRole.new
        respond_with(@site, @site_role)
    end

    def edit
        fail 'Cannot edit Guest role.' if @site_role.guest?
    end

    def create
        @site_role = SiteRole.new( parsed_params )
        @site_role.site = @site

        respond_to do |format|
            if @site_role.save
                format.html { redirect_to site_role_path(@site, @site_role), notice: 'Site role was successfully created.' }
            else
                format.html { render :new }
            end
        end
    end

    def update
        fail 'Cannot update Guest role.' if @site_role.guest?

        respond_to do |format|
            if @site_role.update( parsed_params )
                format.html { redirect_to site_role_path(@site_role.site, @site_role, notice: 'Site role was successfully updated.') }
            else
                format.html { render :edit }
            end
        end
    end

    def destroy
        fail 'Cannot delete Guest role.'      if @site_role.guest?
        fail 'Cannot delete role with scans.' if @site_role.scans.any?

        @site_role.destroy

        respond_to do |format|
            format.html { redirect_to site_roles_path(@site_role.site), status: 303 }
        end
    end

    private

    def set_site
        @site = current_user.sites.find_by_id( params[:site_id] )

        raise ActionController::RoutingError.new( 'Site not found.' ) if !@site
    end

    def set_site_role
        @site_role = @site.roles.find(params[:id])

        @scans = @site_role.scans.includes(:schedule).includes(:device).
            includes(:site_role).includes(:profile).includes(:revisions)
    end

    def set_site_roles
        @site_roles = @site.roles.order( id: :asc )
    end

    def permitted_attributes
        super | [
            :name,
            :description,
            :login_type,

            :login_form_url,
            :login_form_parameters,

            :login_script_code
        ]
    end

    def permitted_parsed_attributes
        super | [{ login_form_parameters: {} }]
    end

    def parsed_params
        pp  = super

        if permitted_params[:login_form_parameters]
            pp[:login_form_parameters] = parse_lsv_to_hash(
                permitted_params[:login_form_parameters]
            )
        end

        pp
    end
end
