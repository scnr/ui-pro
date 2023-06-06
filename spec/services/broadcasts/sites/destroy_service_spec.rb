# frozen_string_literal: true

RSpec.describe Broadcasts::Sites::DestroyService do
  subject(:service) { described_class.call(site_id: site_id, user_id: user_id) }

  let(:user) { create(:user) }

  shared_examples 'does not broadcast the message' do
    it { is_expected.to be_falsey }

    it 'does not broadcast the message' do
      expect { service }.not_to have_broadcasted_to.from_channel(SiteChannel)
    end
  end

  describe 'Success' do
    let(:site_id) { rand(1..3) }
    let(:user_id) { user.id }
    let(:channel_params) do
      {
        site_id: site_id,
        action: 'destroy'
      }
    end

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect { service }.to have_broadcasted_to(user).from_channel(SiteChannel).with(**channel_params)
    end
  end

  describe 'Failure' do
    context 'when site_id is not present' do
      let(:site_id) { nil }
      let(:user_id) { user.id }

      include_examples 'does not broadcast the message'
    end

    context 'when user_id is not present' do
      let(:site_id) { rand(1..3) }
      let(:user_id) { nil }

      include_examples 'does not broadcast the message'
    end

    context 'when user is not found' do
      let(:site_id) { rand(1..3) }
      let(:user_id) { 0 }

      include_examples 'does not broadcast the message'
    end
  end
end
