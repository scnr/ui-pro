class IssueType < ActiveRecord::Base
    has_one  :severity,   class_name: 'IssueTypeSeverity',
             foreign_key: 'issue_type_id'
    has_many :tags,       class_name: 'IssueTypeTag',
             foreign_key: 'issue_type_id'
    has_many :references, class_name: 'IssueTypeReference',
             foreign_key: 'issue_type_id'
    has_many :issues
end
