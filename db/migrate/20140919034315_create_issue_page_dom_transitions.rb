class CreateIssuePageDomTransitions < ActiveRecord::Migration
    def change
        create_table :issue_page_dom_transitions do |t|
            t.text :element
            t.text :event
            t.text :options
            t.float :time
            t.belongs_to :issue_page_dom, index: true

            t.timestamps
        end
    end
end
