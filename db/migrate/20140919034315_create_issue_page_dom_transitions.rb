class CreateIssuePageDomTransitions < ActiveRecord::Migration[5.1]
    def change
        create_table :issue_page_dom_transitions do |t|
            t.binary :element
            t.text :event
            t.binary :options
            t.float :time
            t.belongs_to :issue_page_dom, index: true

            t.timestamps
        end
    end
end
