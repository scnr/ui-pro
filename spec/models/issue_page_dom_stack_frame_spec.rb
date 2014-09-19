require 'spec_helper'

describe IssuePageDomStackFrame do
    expect_it { to belong_to :with_dom_stack_frame }
    expect_it { to have_one :function }
end
