class SchedulesController < ApplicationController
    before_filter :authenticate_user!
    after_action :verify_authorized

    # GET /schedules
    # GET /schedules.json
    def index
        # TODO: This doesn't seem optimised.
        @schedules = policy_scope( Scan ).map(&:schedule)
        authorize Schedule
    end

end
