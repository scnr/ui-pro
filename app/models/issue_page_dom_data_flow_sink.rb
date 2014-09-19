class IssuePageDomDataFlowSink < ActiveRecord::Base
    belongs_to :dom, class_name: 'IssuePageDom', foreign_key: 'issue_page_dom_id'

    has_one  :function,    as: :with_dom_function,
             class_name: 'IssuePageDomFunction'
    has_many :stackframes, as: :with_dom_stack_frame,
             class_name: 'IssuePageDomStackFrame'
end
