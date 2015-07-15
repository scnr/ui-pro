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

    FREQUENCY_BASES = %w(start stop)
    validates_inclusion_of :frequency_base, in: FREQUENCY_BASES, allow_nil: true

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

    before_save :set_default_values

    # Will not return nil #start_at.
    scope :due, -> { where( 'start_at <= ?', Time.now ) }
    default_scope { order(:start_at) }

    def due?
        start_at && start_at < Time.now
    end

    def suspended?
        scan.suspended?
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
        frequency > 0
    end

    def frequency
        day_frequency.to_i.days + month_frequency.to_i.months
    end

    def scheduled?
        !!self.start_at
    end

    def unschedule
        self.start_at = nil
        save
    end

    def frequency_based_on_start_time?
        frequency_base == 'start'
    end

    def frequency_based_on_stop_time?
        frequency_base == 'finish'
    end

    def schedule_next
        return if !recurring?

        lr   = scan.last_revision
        base = (frequency_based_on_start_time? ? lr.started_at : lr.stopped_at)

        self.start_at = base + frequency

        save
    end

    private

    def set_default_values
        self.frequency_base ||= 'start'
    end

end
