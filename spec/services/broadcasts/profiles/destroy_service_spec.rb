# frozen_string_literal: true

RSpec.describe Broadcasts::Profiles::DestroyService do
  subject(:service) { described_class.call(profile_id: profile_id, user_id: user_id) }

  shared_examples 'does not broadcast the message' do
    it 'does not broadcast the message' do
      expect(ProfileChannel).not_to receive(:broadcast_to)
      service
    end
  end

  describe 'Success' do
    let(:user) { create(:user) }
    let(:profile_id) { rand(1..3) }
    let(:user_id) { user.id }
    let(:channel_params) do
      {
        profile_id: profile_id,
        action: :destroy
      }
    end

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect(ProfileChannel).to receive(:broadcast_to).with(user, **channel_params)
      service
    end
  end

  describe 'Failure' do
    context 'when profile_id is not present' do
      let(:profile_id) { nil }
      let(:user_id) { rand(1..3) }

      it { is_expected.to be_falsey }

      include_examples 'does not broadcast the message'
    end

    context 'when user_id is not present' do
      let(:profile_id) { rand(1..3) }
      let(:user_id) { nil }

      it { is_expected.to be_falsey }

      include_examples 'does not broadcast the message'
    end

    context 'when user is not found' do
      let(:profile_id) { 0 }
      let(:user_id) { rand(1..3) }

      it { is_expected.to be_falsey }

      include_examples 'does not broadcast the message'
    end
  end
end
