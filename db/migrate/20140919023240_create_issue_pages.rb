class CreateIssuePages < ActiveRecord::Migration
    def change
        create_table :issue_pages do |t|
            t.belongs_to :sitemap_entry
            t.timestamps
        end
    end
end
