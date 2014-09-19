FactoryGirl.define do
    factory :issue_page_dom_transition do
        element "page"
        event "load"
        time 1.5
        dom { FactoryGirl.create :issue_page_dom }
    end
end
