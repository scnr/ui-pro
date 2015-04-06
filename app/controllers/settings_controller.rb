class SettingsController < ApplicationController
    before_filter :authenticate_user!

    before_action :set_settings, only: [:index, :show, :edit, :update]

    def index
        render :edit
    end

    def show
        render :edit
    end

    def edit
    end

    def update
        respond_to do |format|
            if @settings.update( settings_params )
                format.html do
                    redirect_to @settings, notice: 'Settings were successfully updated.'
                end
                format.json { render :show, status: :ok, location: @settings }
            else
                format.html { render :show }
                format.json { render json: @settings.errors, status: :unprocessable_entity }
            end
        end

    end

    private

    def set_settings
        @settings = Setting.first
    end

    def settings_params
        params.require( :setting ).permit(*[
            :http_request_timeout,
            :http_request_queue_size,
            :http_request_redirect_limit,
            :http_response_max_size,
            :http_proxy_host,
            :http_proxy_port,
            :http_proxy_username,
            :http_proxy_password,

            :browser_cluster_pool_size,
            :browser_cluster_job_timeout,
            :browser_cluster_worker_time_to_live,
        ])
    end
end
