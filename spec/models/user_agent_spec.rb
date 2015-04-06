require 'rails_helper'

describe UserAgent, type: :model do
    subject { FactoryGirl.create :user_agent }

    expect_it { to have_many :scans }
    expect_it { to have_many :revisions }
    expect_it { to validate_uniqueness_of :name }
    expect_it { to validate_presence_of :name }
    expect_it { to validate_presence_of :http_user_agent }
    expect_it { to validate_presence_of :browser_cluster_screen_width }
    expect_it { to validate_numericality_of :browser_cluster_screen_width }
    expect_it { to validate_presence_of :browser_cluster_screen_height }
    expect_it { to validate_numericality_of :browser_cluster_screen_height }
end
