class CreateIssuePageDoms < ActiveRecord::Migration
    def change
        create_table :issue_page_doms do |t|
            t.text :url
            t.binary :body
            t.belongs_to :issue_page, index: true

            t.timestamps
        end

        add_index :issue_page_doms, :url
    end
end
