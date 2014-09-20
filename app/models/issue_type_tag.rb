class IssueTypeTag < ActiveRecord::Base
    has_and_belongs_to_many :types, class_name: 'IssueType',
        foreign_key: 'issue_type_id',
        join_table: 'issue_types_issue_type_tags'
end
