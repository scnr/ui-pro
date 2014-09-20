require 'spec_helper'

describe IssueTypeReference do
    expect_it { to have_many :types }
end
