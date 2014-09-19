class IssuePageDomStackFrame < ActiveRecord::Base
    belongs_to :with_dom_stack_frame, polymorphic: true
    has_one    :function, as: :with_dom_function,
               class_name: 'IssuePageDomFunction'
end
