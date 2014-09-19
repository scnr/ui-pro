class IssuePageDomDataFlowSink < ActiveRecord::Base
    belongs_to :issue_page_dom
    has_one  :function,    as: :with_dom_function,
             class_name: 'IssuePageDomFunction'
    has_many :stackframes, as: :with_dom_stack_frame,
             class_name: 'IssuePageDomStackFrame'
end
