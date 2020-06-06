class IssuePageDomExecutionFlowSink < ActiveRecord::Base
    belongs_to :dom, class_name: 'IssuePageDom',
               foreign_key: 'issue_page_dom_id',
               optional: true

    has_many :stackframes, as: :with_dom_stack_frame,
             class_name: 'IssuePageDomStackFrame', dependent: :destroy

    serialize :data, CustomSerializer # Array

    def self.create_from_engine( sink )
        create(
            data:        sink.data,
            stackframes: sink.trace.map do |frame|
                IssuePageDomStackFrame.create_from_engine( frame )
            end
        )
    end
end
