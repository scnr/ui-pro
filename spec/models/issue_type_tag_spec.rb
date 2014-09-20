require 'spec_helper'

describe IssueTypeTag do
    expect_it { to have_many :types }
end
