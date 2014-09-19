FactoryGirl.define do
    factory :issue_page_dom_execution_flow_sink do
        issue_page_dom { FactoryGirl.create :issue_page_dom }
        stackframes { [FactoryGirl.create(:issue_page_dom_stack_frame)] }
    end
end
