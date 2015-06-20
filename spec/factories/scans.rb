FactoryGirl.define do
    factory :scan do
        site nil
        path '/my-path'
        name { "MyString #{rand(99999)}" }
        description 'MyText'
        profile { FactoryGirl.create( :profile, name: "MyString #{rand(99999)}" ) }
        user_agent { FactoryGirl.create( :user_agent, name: "MyString #{rand(99999)}" ) }
        site_role { FactoryGirl.create( :site_role ) }
        # site { FactoryGirl.create( :site, user: FactoryGirl.create( :user ) ) }
    end
end
