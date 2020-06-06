class CreateIssueTypeSeverities < ActiveRecord::Migration[5.1]
    def change
        create_table :issue_type_severities do |t|
            t.string :name
            t.text :description

            t.timestamps
        end
        add_index :issue_type_severities, :name, unique: true
    end
end
