class IssuePageDom < ActiveRecord::Base
    belongs_to :page, class_name: 'IssuePage', foreign_key: 'issue_page_id'

    has_many   :transitions,         class_name: 'IssuePageDomTransition'
    has_many   :data_flow_sinks,     class_name: 'IssuePageDomDataFlowSink'
    has_many   :execution_flow_sink, class_name: 'IssuePageDomExecutionFlowSink'
end
