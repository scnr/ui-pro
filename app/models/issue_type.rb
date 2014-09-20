class IssueType < ActiveRecord::Base
    belongs_to :severity, class_name: 'IssueTypeSeverity',
             foreign_key: 'issue_type_severity_id'

    has_and_belongs_to_many :tags, class_name: 'IssueTypeTag',
             foreign_key: 'issue_type_tag_id',
             join_table: 'issue_types_issue_type_tags'

    has_many :references, class_name: 'IssueTypeReference',
             foreign_key: 'issue_type_id'

    has_many :issues
end
