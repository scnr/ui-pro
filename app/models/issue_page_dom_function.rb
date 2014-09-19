class IssuePageDomFunction < ActiveRecord::Base
    belongs_to :with_dom_function, polymorphic: true

    serialize :arguments, Array
end
