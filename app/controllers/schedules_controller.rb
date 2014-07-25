class SchedulesController < ApplicationController
    before_filter :authenticate_user!
    after_action :verify_authorized

    before_action :set_schedule, only: [:show]

    # GET /schedules
    # GET /schedules.json
    def index
        # TODO: This doesn't seem optimised.
        @schedules = policy_scope( Scan ).map(&:schedule)
        authorize Schedule
    end

    # GET /schedules/1
    # GET /schedules/1.json
    def show
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
        authorize @schedule = Schedule.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def schedule_params
        params.require(:schedule).
            permit( *policy(@schedule || Schedule).permitted_attributes )
    end
end
