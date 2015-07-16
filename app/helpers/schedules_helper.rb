module SchedulesHelper

    def render_schedule( schedule )
        render partial: '/shared/schedule', locals: { schedule: schedule }
    end

    def render_frequency( schedule )
        if schedule.frequency_simple?
            schedule.human_frequency
        else
            "<kbd>#{schedule.frequency_cron}</kbd>".html_safe
        end
    end

end
