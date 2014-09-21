class IssuePageDom < ActiveRecord::Base
    belongs_to :page, class_name: 'IssuePage', foreign_key: 'issue_page_id'

    has_many :transitions,          class_name: 'IssuePageDomTransition'
    has_many :data_flow_sinks,      class_name: 'IssuePageDomDataFlowSink'
    has_many :execution_flow_sinks, class_name: 'IssuePageDomExecutionFlowSink'

    def self.create_from_arachni( dom )
        create(
            url:                  dom.url,
            body:                 dom.page.body,
            transitions:          dom.transitions.map do |transition|
                IssuePageDomTransition.create_from_arachni( transition )
            end,
            data_flow_sinks:      dom.data_flow_sinks.map do |sink|
                IssuePageDomDataFlowSink.create_from_arachni( sink )
            end,
            execution_flow_sinks: dom.execution_flow_sinks.map do |sink|
                IssuePageDomExecutionFlowSink.create_from_arachni( sink )
            end
        )
    end
end
