FactoryGirl.define do
    factory :user do
        name "Test User"
        email { "test#{rand(99999999)}@example.com" }
        password "please123"
    end
end
