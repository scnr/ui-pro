FactoryGirl.define do
    factory :issue do
        digest "MyString"
        signature "MyText"
        proof "MyText"
        trusted false
    end
end
