require 'spec_helper'

describe IssueRemark do
    expect_it { to belong_to :issue }
end
