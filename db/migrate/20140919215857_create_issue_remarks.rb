class CreateIssueRemarks < ActiveRecord::Migration
    def change
        create_table :issue_remarks do |t|
            t.string :author
            t.text :text
            t.belongs_to :issue, index: true

            t.timestamps
        end
    end
end
