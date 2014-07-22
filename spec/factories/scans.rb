# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :scan do
        site nil
        name 'MyString'
        description 'MyText'
        profile FactoryGirl.create(:profile)
    end
end
