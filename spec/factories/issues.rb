FactoryGirl.define do
    factory :issue do
        digest { rand( 99999999 ) }
        signature "MyText"
        proof "MyText"
        state 'trusted'
        active false
    end
end
