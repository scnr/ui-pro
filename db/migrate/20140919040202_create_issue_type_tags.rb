class CreateIssueTypeTags < ActiveRecord::Migration[5.1]
    def change
        create_table :issue_type_tags do |t|
            t.string :name
            t.text :description

            t.timestamps
        end
        add_index :issue_type_tags, :name, unique: true
    end
end
