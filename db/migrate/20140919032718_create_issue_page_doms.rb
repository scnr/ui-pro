class CreateIssuePageDoms < ActiveRecord::Migration
    def change
        create_table :issue_page_doms do |t|
            t.string :url
            t.text :body
            t.belongs_to :issue_page, index: true

            t.timestamps
        end
    end
end
