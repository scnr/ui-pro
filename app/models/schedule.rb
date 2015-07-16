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

    FREQUENCY_BASES   = %w(start stop)
    FREQUENCY_FORMATS = %w(simple cron)

    validates_inclusion_of :frequency_base,   in: FREQUENCY_BASES, allow_nil: true
    validates_inclusion_of :frequency_format, in: FREQUENCY_FORMATS, allow_nil: true

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

    validate :validate_cron

    before_save :sanitize_start_at
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

    def scheduled?
        !!self.start_at
    end

    def unschedule
        self.start_at = nil
        save
    end

    def recurring?
        frequency_simple? || frequency_cron?
    end

    def frequency_based_on_start_time?
        frequency_base == 'start'
    end

    def frequency_based_on_stop_time?
        frequency_base == 'stop'
    end

    def frequency_simple?
        frequency_format == 'simple' && (day_frequency || month_frequency)
    end

    def frequency_cron?
        frequency_format == 'cron' && !frequency_cron.to_s.empty?
    end

    def next( base )
        return if !recurring?

        frequency_cron? ?
            frequency_cron_next( base ) : frequency_simple_next( base )
    end

    def schedule_next
        return if !recurring?

        lr   = scan.last_revision
        base = (frequency_based_on_start_time? ? lr.started_at : lr.stopped_at)

        self.start_at = self.next( base )

        save
    end

    def human_frequency
        if frequency_simple?
            parts = []

            if day_frequency
                parts << "#{day_frequency} #{'day'.pluralize( day_frequency )}"
            end

            if month_frequency
                parts << "#{month_frequency} #{'month'.pluralize( month_frequency )}"
            end

            "every #{parts.join( ' & ' )}"
        else
            "#{frequency_cron}"
        end
    end

    def to_s
        s = ''
        if self.start_at
            s = "on #{I18n.localize( self.start_at )}"
        end

        return s if !recurring?

        "#{s} - #{human_frequency}"
    end

    private

    def validate_cron
        return if !frequency_cron?

        begin
            cron_parser
        rescue => e
            errors.add :frequency_cron, e.to_s
        end
    end

    def frequency_cron_next( base )
        cron_parser.next( base )
    end

    def cron_parser
        CronParser.new( self.frequency_cron )
    end

    def frequency_simple_next( base )
        base + (day_frequency.to_i.days + month_frequency.to_i.months)
    end

    def sanitize_start_at
        return if !self.start_at

        self.start_at = [self.start_at, Time.now].max
    end

    def set_default_values
        self.frequency_format ||= 'simple'
        self.frequency_base   ||= 'start'
    end

end
