class DevicesController < ApplicationController
    include ProfilesControllerExportable
    include ProfilesControllerImportable

    before_action :authenticate_user!

    before_action :set_device,
                  only: [:show, :edit, :copy, :update, :default, :destroy]
    before_action :set_devices,
                  only: [:index, :default]

    before_action :authorize_edit,    only: [:edit, :update]
    before_action :authorize_destroy, only: [:destroy]

    PROFILE_EXPORT_PREFIX = 'SCNR::Pro device'

    respond_to :html

    def index
        respond_with(@devices)
    end

    def new
        @device = Device.new
        respond_with(@device)
    end

    def edit
    end

    def copy
        @device = @device.dup
        render :new
    end

    def create
        @device = Device.new( device_params )

        if @device.save
            flash[:notice] = 'User agent was successfully created.'
        end

        respond_with(@device)
    end

    def update
        if @device.update( device_params )
            flash[:notice] = 'User agent was successfully updated.'
        end

        respond_with(@device)
    end

    def default
        @device.default!
        render partial: 'table', formats: :js
    end

    def destroy
        @device.destroy
        respond_with(@device)
    end

    private

    def authorize_edit
        return if @device.scans.empty?
        redirect_to @device,
                    error: 'Cannot edit a user agent that has associated scans.'
    end

    def authorize_destroy
        return if @device.scans.empty?
        redirect_to @device,
                    error: 'Cannot delete a user agent that has associated scans.'
    end

    def set_device
        @device = Device.find(params[:id])

        @scans = @device.scans.includes(:schedule).includes(:device).
            includes(:site_role).includes(:profile).includes(:revisions)
    end

    def set_devices
        @devices = Device.all.order( id: :asc )
    end

    def device_params
        params.require(:device).permit(
            :name,
            :device_user_agent,
            :device_width,
            :device_height,
            :device_touch,
            :device_pixel_ratio
        )
    end
end
