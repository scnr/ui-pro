require 'spec_helper'

describe IssuePageDomExecutionFlowSink do
    expect_it { to belong_to :issue_page_dom }
    expect_it { to have_many :stackframes }
end
