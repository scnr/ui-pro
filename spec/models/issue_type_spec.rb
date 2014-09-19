require 'spec_helper'

describe IssueType do
    expect_it { to have_one :severity }
    expect_it { to have_many :tags }
    expect_it { to have_many :references }
    expect_it { to have_many :issues }
end
