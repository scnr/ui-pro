class SchedulesController < ApplicationController
    before_filter :authenticate_user!

    before_action :set_site

    respond_to :html, :js

    # GET /schedules
    # GET /schedules.json
    def index
        @schedules = @site.schedules
    end

    private

    def set_site
        @site = current_user.sites.find_by_id( params[:site_id] )

        raise ActionController::RoutingError.new( 'Site not found.' ) if !@site
    end
end
