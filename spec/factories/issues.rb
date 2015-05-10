FactoryGirl.define do
    factory :issue do
        digest "MyString"
        signature "MyText"
        proof "MyText"
        state 'trusted'
        active false
    end
end
