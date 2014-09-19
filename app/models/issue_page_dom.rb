class IssuePageDom < ActiveRecord::Base
    belongs_to :issue_page
    has_many   :transitions,         class_name: 'IssuePageDomTransition'
    has_many   :data_flow_sinks,     class_name: 'IssuePageDomDataFlowSink'
    has_many   :execution_flow_sink, class_name: 'IssuePageDomExecutionFlowSink'
end
