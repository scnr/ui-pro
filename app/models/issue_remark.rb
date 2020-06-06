class IssueRemark < ActiveRecord::Base
    belongs_to :issue, optional: true
end
