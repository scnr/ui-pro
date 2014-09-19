class IssuePageDomExecutionFlowSink < ActiveRecord::Base
    belongs_to :issue_page_dom
    has_many :stackframes, as: :with_dom_stack_frame,
             class_name: 'IssuePageDomStackFrame'
end
