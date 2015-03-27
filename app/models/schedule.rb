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

    before_save :sanitize_start_at

    scope :due, -> { where( 'start_at <= ?', Time.now ) }

    def to_s
        return '' if !recurring?

        s = []

        if day_frequency
            s << "#{day_frequency} #{'days'.pluralize(day_frequency)}"
        end

        if month_frequency
            s << "#{month_frequency} #{'months'.pluralize(month_frequency)}"
        end

        'every ' + s.join( ' & ' )
    end

    def recurring?
        interval > 0
    end

    def interval
        day_frequency.to_i.days + month_frequency.to_i.months
    end

    def schedule_next
        self.start_at += interval
        save
    end

    private

    def sanitize_start_at
        return true if !self.start_at

        self.start_at = [start_at, Time.now].max
        true
    end

end
