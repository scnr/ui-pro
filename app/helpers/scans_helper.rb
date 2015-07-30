module ScansHelper

    def status_to_label( status )
        case status.to_sym

            when :scanning
                'primary'

            when :completed
                'success'

            when :paused, :aborted
                'warning'

            when :suspended
                'default'

            when :failed
                'danger'

            else
                'info'
        end
    end

end
