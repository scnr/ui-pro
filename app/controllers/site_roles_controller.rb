class SiteRolesController < ApplicationController
    before_filter :authenticate_user!

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
        @site_role = SiteRole.new(site_role_params)
        @site_role.site = @site

        if @site_role.save
            flash[:notice] = 'SiteRole was successfully created.'
            render :show
        else
            render :edit
        end
    end

    def update
        fail 'Cannot update Guest role.' if @site_role.guest?

        if @site_role.update(site_role_params)
            flash[:notice] = 'SiteRole was successfully updated.'
            render :show
        else
            render :edit
        end
    end

    def destroy
        fail 'Cannot delete Guest role.'      if @site_role.guest?
        fail 'Cannot delete role with scans.' if @site_role.scans.any?

        @site_role.destroy
        render :index
    end

    private

    def set_site
        @site = current_user.sites.find_by_id( params[:site_id] )

        raise ActionController::RoutingError.new( 'Site not found.' ) if !@site
    end

    def set_site_role
        @site_role = @site.roles.find(params[:id])

        @scans = @site_role.scans.includes(:schedule).includes(:user_agent).
            includes(:site_role).includes(:profile).includes(:revisions)
    end

    def set_site_roles
        @site_roles = @site.roles.order( id: :asc )
    end

    def site_role_params
        params.require(:site_role).permit(
            :name,
            :description,

            :session_check_url,
            :session_check_pattern,

            :scope_exclude_path_patterns,

            :login_type,

            :login_form_url,
            :login_form_parameters,

            :login_script_code
        )
    end
end
