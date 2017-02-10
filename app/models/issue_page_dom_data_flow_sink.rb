class IssuePageDomDataFlowSink < ActiveRecord::Base
    belongs_to :dom, class_name: 'IssuePageDom', foreign_key: 'issue_page_dom_id'

    has_one  :function,    as: :with_dom_function,
             class_name: 'IssuePageDomFunction', dependent: :destroy

    has_many :stackframes, as: :with_dom_stack_frame,
             class_name: 'IssuePageDomStackFrame', dependent: :destroy

    # @return   [String, nil]
    #   Value of the tainted argument.
    def tainted_argument_value
        return if !function.arguments
        function.arguments[tainted_argument_index]
    end

    # @return   [String, nil]
    #   Name of the tainted argument.
    def tainted_argument_name
        return if !function.signature_arguments
        function.signature_arguments[tainted_argument_index]
    end

    def self.create_from_engine( sink )
        create(
            object:                 sink.object,
            taint_value:            sink.taint,
            tainted_value:          sink.tainted_value,
            tainted_argument_index: sink.tainted_argument_index,
            function:               IssuePageDomFunction.create_from_engine( sink.function ),
            stackframes:            sink.trace.map do |frame|
                IssuePageDomStackFrame.create_from_engine( frame )
            end
        )
    end
end
