# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
    factory :scan do
        enabled true
        site nil
        name 'MyString'
        description 'MyText'
    end
end
