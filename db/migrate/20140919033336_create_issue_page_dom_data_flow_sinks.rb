class CreateIssuePageDomDataFlowSinks < ActiveRecord::Migration
    def change
        create_table :issue_page_dom_data_flow_sinks do |t|
            t.text :object
            t.integer :tainted_argument_index
            t.text :tainted_value
            t.text :taint_value
            t.belongs_to :issue_page_dom, index: true

            t.timestamps
        end

        add_index :issue_page_dom_data_flow_sinks, :object
    end
end
