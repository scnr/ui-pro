require 'spec_helper'

describe Plan do
    subject { FactoryGirl.create :plan }

    expect_it { to have_many :scans }
    expect_it { to have_one  :profile }

    it 'has a default #profile' do
        expect(subject.profile).to be_kind_of Profile
    end

end
