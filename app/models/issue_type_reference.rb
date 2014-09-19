class IssueTypeReference < ActiveRecord::Base
    belongs_to :type, class_name: 'IssueType', foreign_key: 'issue_type_id'
end
