# https://github.com/rails/rails/issues/24195
# https://github.com/rails/rails/pull/24202
module ActiveRecord
module AttributeMethods
module TimeZoneConversion
class TimeZoneConverter

    def set_time_zone_without_conversion(value)
        ::Time.zone.local_to_utc(value).try(:in_time_zone)
    end

end
end
end
end
