FactoryGirl.define do
    factory :site do
        protocol 'http'
        host 'test.com'
        port 1
    end
end
