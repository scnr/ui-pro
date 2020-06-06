class CreateIssueTypesIssueTypeTags < ActiveRecord::Migration[5.1]
    def change
        create_table :issue_types_issue_type_tags do |t|
            t.integer :issue_type_id
            t.integer :issue_type_tag_id
        end
    end
end
