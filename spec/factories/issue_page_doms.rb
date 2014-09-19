FactoryGirl.define do
    factory :issue_page_dom do
        url url "http://127.0.0.2:4567/#!/stuff/here"
        body "MyText"
        issue_page { FactoryGirl.create :issue_page }
    end
end
