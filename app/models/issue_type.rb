class IssueType < ActiveRecord::Base
    belongs_to :severity, class_name: 'IssueTypeSeverity',
             foreign_key: 'issue_type_severity_id'

    belongs_to :tags, class_name: 'IssueTypeTag',
             foreign_key: 'issue_type_tag_id'

    belongs_to :references, class_name: 'IssueTypeReference',
             foreign_key: 'issue_type_reference_id'

    has_many :issues
end
