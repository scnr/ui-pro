FactoryGirl.define do
    factory :scan do
        site nil
        name { "MyString #{rand(99999)}" }
        description 'MyText'
        profile FactoryGirl.create( :profile, name: 'My profile' )
        plan { FactoryGirl.create( :plan, name: 'My plan' ) }
        # site { FactoryGirl.create( :site, user: FactoryGirl.create( :user ) ) }
    end
end
