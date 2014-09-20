class CreateIssues < ActiveRecord::Migration
    def change
        create_table :issues do |t|
            t.string :digest
            t.text :signature
            t.text :proof
            t.boolean :trusted
            t.integer :referring_issue_page_id
            t.belongs_to :revision, index: true
            t.belongs_to :issue_page, index: true
            t.belongs_to :issue_type, index: true
            t.belongs_to :issue_platform, index: true

            t.timestamps
        end
        add_index :issues, :referring_issue_page_id
        add_index :issues, :digest
        add_index :issues, :trusted
    end
end
