# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :scan do
        site nil
        name 'MyString'
        description 'MyText'
        profile FactoryGirl.create( :profile, name: 'My profile' )
        plan { FactoryGirl.create( :plan, name: 'My plan' ) }
    end
end
