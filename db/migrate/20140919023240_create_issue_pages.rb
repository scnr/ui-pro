class CreateIssuePages < ActiveRecord::Migration
    def change
        create_table :issue_pages do |t|

            t.timestamps
        end
    end
end
