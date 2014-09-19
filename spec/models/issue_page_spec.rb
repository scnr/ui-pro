require 'spec_helper'

describe IssuePage do
    subject { FactoryGirl.create :issue_page }

    expect_it { to have_one :request }
    expect_it { to have_one :response }
    expect_it { to have_one :dom }
end
