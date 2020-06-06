class CreateIssuePageDomExecutionFlowSinks < ActiveRecord::Migration[5.1]
    def change
        create_table :issue_page_dom_execution_flow_sinks do |t|
            t.binary :data
            t.belongs_to :issue_page_dom, index: true

            t.timestamps
        end
    end
end
