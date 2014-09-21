class IssuePageDomDataFlowSink < ActiveRecord::Base
    belongs_to :dom, class_name: 'IssuePageDom', foreign_key: 'issue_page_dom_id'

    has_one  :function,    as: :with_dom_function,
             class_name: 'IssuePageDomFunction'
    has_many :stackframes, as: :with_dom_stack_frame,
             class_name: 'IssuePageDomStackFrame'

    def self.create_from_arachni( sink )
        create(
            object:                 sink.object,
            taint_value:            sink.taint,
            tainted_value:          sink.tainted_value,
            tainted_argument_index: sink.tainted_argument_index,
            function:               IssuePageDomFunction.create_from_arachni( sink.function ),
            stackframes:            sink.trace.map do |frame|
                IssuePageDomStackFrame.create_from_arachni( frame )
            end
        )
    end
end
