class CreateIssuePageDomExecutionFlowSinks < ActiveRecord::Migration
  def change
    create_table :issue_page_dom_execution_flow_sinks do |t|
      t.belongs_to :issue_page_dom, index: true

      t.timestamps
    end
  end
end
