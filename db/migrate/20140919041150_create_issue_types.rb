class CreateIssueTypes < ActiveRecord::Migration
    def change
        create_table :issue_types do |t|
            t.string :name
            t.string :check_shortname
            t.text :description
            t.text :remedy_guidance
            t.integer :cwe

            t.timestamps
        end
        add_index :issue_types, :name, unique: true
        add_index :issue_types, :check_shortname, unique: true
    end
end
