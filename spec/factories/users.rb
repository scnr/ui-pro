FactoryGirl.define do
    factory :user do
        name "Test User"
        email { "test#{rand(99999999)}@example.com" }
        password "please123"

        trait :admin do
            role 'admin'
        end
    end
end
