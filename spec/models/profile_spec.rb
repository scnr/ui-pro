require 'spec_helper'

describe Profile do
    subject { FactoryGirl.create :profile, user: user }
    let(:other) { FactoryGirl.create :profile, user: user }
    let(:user) { FactoryGirl.create :user }

    expect_it { to belong_to :user }
    expect_it { to have_many :scans }

    describe '#to_s' do
        it 'returns #name' do
            expect(subject.to_s).to eq subject.name
        end
    end

end
