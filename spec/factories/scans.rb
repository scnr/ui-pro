FactoryGirl.define do
    factory :scan do
        site { FactoryGirl.create( :site, user: FactoryGirl.create( :user ) ) }
        path '/my-path'
        name { "MyString #{rand(99999)}" }
        description 'MyText'
        profile { FactoryGirl.create( :profile, name: "MyString #{rand(99999)}" ) }
        device { FactoryGirl.create( :device, name: "MyString #{rand(99999)}" ) }
        site_role { FactoryGirl.create( :site_role ) }

        trait :with_scheduled_status do
            after(:create) do |scan|
                create(:schedule, scan: scan)
            end
        end

        trait :with_suspended_status do
            status { :suspended }
        end

        trait :with_active_status do
            status { Scan::ACTIVE_STATES.sample }
        end

        trait :with_finished_status do
            status { Scan::FINISHED_STATES.sample }
        end
    end
end
