require 'spec_helper'

describe Issue do
    expect_it { to belong_to :page }
    expect_it { to belong_to :referring_page }
    expect_it { to belong_to :type }
    expect_it { to belong_to :platform }
    expect_it { to have_one :vector }
    expect_it { to have_many :remarks }
end
