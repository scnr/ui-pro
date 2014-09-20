class CreateIssueTypeReferences < ActiveRecord::Migration
    def change
        create_table :issue_type_references do |t|
            t.string :title
            t.text :url

            t.timestamps
        end
        add_index :issue_type_references, :title, unique: true
        add_index :issue_type_references, :url, unique: true
    end
end
