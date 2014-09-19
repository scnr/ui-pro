require 'spec_helper'

describe IssuePageDomDataFlowSink do
    expect_it { to belong_to :issue_page_dom }
    expect_it { to have_one :function }
    expect_it { to have_many :stackframes }
end
