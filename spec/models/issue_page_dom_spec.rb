require 'spec_helper'

describe IssuePageDom do
    expect_it { to belong_to :page }
    expect_it { to have_many :transitions }
    expect_it { to have_many :data_flow_sinks }
    expect_it { to have_many :execution_flow_sinks }
end
