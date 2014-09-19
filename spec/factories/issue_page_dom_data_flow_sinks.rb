FactoryGirl.define do
    factory :issue_page_dom_data_flow_sink do
        object "window"
        tainted_argument_index 1
        tainted_value "Stuff mytaint blah"
        taint_value "mytaint"
        issue_page_dom { FactoryGirl.create :issue_page_dom }
        function { FactoryGirl.create :issue_page_dom_function }
        stackframes { [FactoryGirl.create(:issue_page_dom_stack_frame)] }
    end
end
