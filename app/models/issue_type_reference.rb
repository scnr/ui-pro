class IssueTypeReference < ActiveRecord::Base
    belongs_to :types, class_name: 'IssueType', foreign_key: 'issue_type_id'
end
