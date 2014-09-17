FactoryGirl.define do
    factory :plan do
        name { "MyString#{rand(99999)}" }
        description "MyText"
        price 15
        enabled false
    end
end
