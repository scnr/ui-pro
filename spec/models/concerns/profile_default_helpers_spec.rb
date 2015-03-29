require 'spec_helper'

describe ProfileDefaultHelpers do
    subject { FactoryGirl.create :profile, user: user }
    let(:other) { FactoryGirl.create :profile, user: user }
    let(:user) { FactoryGirl.create :user }

    describe '.default' do
        it 'returns the default profile' do
            subject.default!
            other

            expect(Profile.default).to eq subject
        end
    end

    describe '#default!' do
        it 'makes the given profile the default one' do
            subject.default!
            expect(subject).to be_default
        end

        it 'removes the default status from the previous default profile' do
            subject.default!
            expect(subject).to be_default

            other.default!

            expect(other.reload).to be_default
            expect(subject.reload).to_not be_default
        end
    end

end
