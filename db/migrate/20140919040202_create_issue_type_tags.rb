class CreateIssueTypeTags < ActiveRecord::Migration
    def change
        create_table :issue_type_tags do |t|
            t.string :name
            t.text :description
            t.belongs_to :issue_type, index: true

            t.timestamps
        end
        add_index :issue_type_tags, :name, unique: true
    end
end
