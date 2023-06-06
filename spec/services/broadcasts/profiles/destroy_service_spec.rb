# frozen_string_literal: true

RSpec.describe Broadcasts::Profiles::DestroyService do
  subject(:service) { described_class.call(profile_id: profile_id, user_id: user_id) }

  shared_examples 'does not broadcast the message' do
    it { is_expected.to be_falsey }

    it 'does not broadcast the message' do
      expect { service }.not_to have_broadcasted_to.from_channel(ProfileChannel)
    end
  end

  describe 'Success' do
    let(:user) { create(:user) }
    let(:profile_id) { rand(1..3) }
    let(:user_id) { user.id }
    let(:channel_params) do
      {
        profile_id: profile_id,
        action: 'destroy'
      }
    end

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect { service }.to have_broadcasted_to(user).from_channel(ProfileChannel).with(**channel_params)
    end
  end

  describe 'Failure' do
    context 'when profile_id is not present' do
      let(:profile_id) { nil }
      let(:user_id) { rand(1..3) }

      include_examples 'does not broadcast the message'
    end

    context 'when user_id is not present' do
      let(:profile_id) { rand(1..3) }
      let(:user_id) { nil }

      include_examples 'does not broadcast the message'
    end

    context 'when user is not found' do
      let(:profile_id) { 0 }
      let(:user_id) { rand(1..3) }

      include_examples 'does not broadcast the message'
    end
  end
end
