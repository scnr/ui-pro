# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :schedule do
        month_frequency 1
        day_frequency 1
        start_at "2014-07-22 08:45:18"
        stop_after_hours 11.2
    end
end
