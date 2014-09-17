FactoryGirl.define do
    factory :site do
        protocol 'http'
        host { "test#{rand(99999)}.com" }
        port 1
    end
end
