require 'rails_helper'

describe Device, type: :model do
    subject { FactoryGirl.create :device }

    expect_it { to have_many :scans }
    expect_it { to have_many :revisions }
    expect_it { to validate_uniqueness_of :name }
    expect_it { to validate_presence_of :name }
    expect_it { to validate_presence_of :device_user_agent }
    expect_it { to validate_presence_of :device_width }
    expect_it { to validate_numericality_of :device_width }
    expect_it { to validate_presence_of :device_height }
    expect_it { to validate_numericality_of :device_height }
end
