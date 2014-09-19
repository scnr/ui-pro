require 'spec_helper'

describe PageDomStackFrame do
    expect_it { to belong_to :traceable }
    expect_it { to have_one :function }
end
