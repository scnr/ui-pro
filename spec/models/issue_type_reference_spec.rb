require 'spec_helper'

describe IssueTypeReference do
    expect_it { to belong_to :type }
end
