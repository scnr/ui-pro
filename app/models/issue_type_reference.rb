class IssueTypeReference < ActiveRecord::Base
    has_many :types, class_name: 'IssueType'
end
