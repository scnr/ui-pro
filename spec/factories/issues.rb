FactoryGirl.define do
    factory :issue do
        to_create { |instance| instance.save( validate: false ) }

        digest { rand( 99999999 ) }
        signature "MyText"
        proof "MyText"
        state 'trusted'
        active false
        type { FactoryGirl.create :issue_type }
    end
end
