require 'spec_helper'

describe IssueType do
    expect_it { to belong_to :severity }
    expect_it { to have_and_belong_to_many :tags }
    expect_it { to have_many :references }
    expect_it { to have_many :issues }
end
