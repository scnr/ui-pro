class CreateIssueTypeReferences < ActiveRecord::Migration[5.1]
    def change
        create_table :issue_type_references do |t|
            t.string :title
            t.text :url
            t.belongs_to :issue_type, index: true

            t.timestamps
        end
    end
end
