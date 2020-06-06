FactoryGirl.define do
    factory :issue_page_dom do
        to_create { |instance| instance.save( validate: false ) }

        url "http://127.0.0.2:4567/#!/stuff/here"
        body "MyText"
    end
end
