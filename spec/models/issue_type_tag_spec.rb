require 'spec_helper'

describe IssueTypeTag do
    expect_it { to belong_to :type }
end
