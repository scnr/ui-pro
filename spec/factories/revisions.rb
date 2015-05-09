# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :revision do
        scan nil
        state "MyString"
        started_at "2014-07-25 15:23:09"
        stopped_at "2014-07-25 15:23:10"
        snapshot_location "MyString"
    end
end
