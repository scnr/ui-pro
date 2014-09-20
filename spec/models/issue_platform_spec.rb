require 'spec_helper'

describe IssuePlatform do
    expect_it { to belong_to :type }
    expect_it { to have_many :issues }
end
