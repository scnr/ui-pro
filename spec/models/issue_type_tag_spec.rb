require 'spec_helper'

describe IssueTypeTag do
    expect_it { to have_and_belong_to_many :types }
end
