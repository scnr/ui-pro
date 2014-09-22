class IssuePageDomExecutionFlowSink < ActiveRecord::Base
    belongs_to :dom, class_name: 'IssuePageDom', foreign_key: 'issue_page_dom_id'

    has_many :stackframes, as: :with_dom_stack_frame,
             class_name: 'IssuePageDomStackFrame', dependent: :destroy

    def self.create_from_arachni( sink )
        create(
            stackframes: sink.trace.map do |frame|
                IssuePageDomStackFrame.create_from_arachni( frame )
            end
        )
    end
end
