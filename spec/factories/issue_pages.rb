FactoryGirl.define do
    factory :issue_page do
        request { FactoryGirl.create :http_request }
        response { FactoryGirl.create :http_response }
        dom { FactoryGirl.create :issue_page_dom }
    end
end
