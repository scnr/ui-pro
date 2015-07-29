class CreateIssues < ActiveRecord::Migration
    def change
        create_table :issues do |t|
            t.bigint :digest
            t.string :state

            t.boolean :active
            t.binary :proof
            t.binary :signature

            t.integer :referring_issue_page_id
            t.integer :reviewed_by_revision_id
            t.belongs_to :revision, index: true
            t.belongs_to :scan, index: true
            t.belongs_to :site, index: true
            t.belongs_to :issue_page, index: true
            t.belongs_to :issue_type, index: true
            t.belongs_to :issue_platform, index: true
            t.belongs_to :sitemap_entry, index: true

            t.timestamps
        end

        add_index :issues, :referring_issue_page_id
        add_index :issues, :digest
        add_index :issues, :state
        add_index :issues, :active
    end
end
