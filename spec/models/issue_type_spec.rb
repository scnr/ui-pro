require 'spec_helper'

describe IssueType do
    expect_it { to belong_to :severity }
    expect_it { to belong_to :tags }
    expect_it { to belong_to :references }
    expect_it { to have_many :issues }
end
