class SchedulesController < ApplicationController
    before_filter :authenticate_user!

    # GET /schedules
    # GET /schedules.json
    def index
        @schedules = Schedule.all
    end

end
