FactoryGirl.define do
    factory :issue_type_reference do
        to_create { |instance| instance.save( validate: false ) }

        title 'My Title'
        url 'http://test.com/my-title/'
    end
end
