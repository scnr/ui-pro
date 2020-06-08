FactoryGirl.define do
    factory :site do
        to_create { |instance| instance.save( validate: false ) }

        protocol 'http'
        host { "test#{rand(99999)}.com" }
        port 1
        profile { FactoryGirl.create :site_profile }
    end
end
