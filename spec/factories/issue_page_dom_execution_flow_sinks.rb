FactoryGirl.define do
    factory :issue_page_dom_execution_flow_sink do
        stackframes { [FactoryGirl.create(:issue_page_dom_stack_frame)] }
    end
end
