class DatetimeValidator < ActiveModel::EachValidator
    def validate_each( record, attribute, value )
        before_type_cast = "#{attribute}_before_type_cast"

        raw_value = record.send( before_type_cast ) if record.respond_to?( before_type_cast.to_sym )
        raw_value ||= value

        return if raw_value.blank?
        raw_value.to_datetime rescue record.errors[attribute] << (options[:message] || 'must be a datetime.')
    end
end

class Schedule < ActiveRecord::Base
    belongs_to :scan

    validates :day_frequency,
              numericality: true,
              inclusion:    {
                  in:       1..29,
                  message: 'Accepted values: 1-29.'
              },
              allow_nil:    true

    validates :month_frequency,
              numericality: true,
              inclusion:    {
                  in:       1..12,
                  message: 'Accepted values: 1-12.'
              },
              allow_nil:    true

    validates :start_at, datetime: true
    validates :stop_after_hours, numericality: { greater_than: 0 }, allow_nil: true

    # All schedules should start with a `#start_at`.
    #
    # However, if the #start_at becomes `nil`, that should remove them from being
    # considered.
    #
    # Useful for recurring active scans, as we can temporarily remove the
    # `#start_at` until the scan finishes, at which point it gets recalculated
    # based on the finish time and the set freq.
    after_create :ensure_start_at

    # Will not return nil #start_at.
    scope :due, -> { where( 'start_at <= ?', Time.zone.now ) }
    default_scope { order(:start_at) }

    def due?
        start_at && start_at < Time.zone.now
    end

    def in_progress?
        !start_at
    end

    def to_s
        s = ''
        if self.start_at
            s = "on #{I18n.localize( self.start_at )}"
        end

        return s if !recurring?

        parts = []

        if day_frequency
            parts << "#{day_frequency} #{'day'.pluralize( day_frequency )}"
        end

        if month_frequency
            parts << "#{month_frequency} #{'month'.pluralize( month_frequency )}"
        end

        s << ' - ' if !s.empty?

        s + 'every ' + parts.join( ' & ' )
    end

    def recurring?
        interval > 0
    end

    def interval
        day_frequency.to_i.days + month_frequency.to_i.months
    end

    def schedule_next
        self.start_at = Time.zone.now + interval
        save
    end

    private

    def ensure_start_at
        self.start_at = [start_at || Time.zone.now, Time.zone.now].max
        true
    end

end
