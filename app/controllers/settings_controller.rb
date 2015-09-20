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
                @@slots_total_auto = nil

                # The interface may need to perform certain operations too,
                # so apply the settings to the global libs for the interface
                # process.
                Arachni::Options.update @settings.to_rpc_options
                Arachni::HTTP::Client.reset

                format.html { render :edit }
                format.json { render :show, status: :ok, location: @settings }
            else
                format.html { render :edit }
                format.json { render json: @settings.errors, status: :unprocessable_entity }
            end
        end
    end

    private

    def set_settings
        @settings = Settings.record

        # TODO: Quite slow when a few scans are running.
        @slots_total_auto = (@@slots_total_auto ||= ScanScheduler.slots_total_auto)
    end

    def settings_params
        if params[:setting].delete( :max_parallel_scans_auto )
            params[:setting][:max_parallel_scans] = nil
        end

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

            :max_parallel_scans
        ])
    end
end
