FactoryGirl.define do
    factory :user do
        name "Test User"
        email "test@example.com"
        password "please123"

        trait :admin do
            role 'admin'
        end

        plan { FactoryGirl.create( :plan, name: 'My plan' ) }
    end
end
