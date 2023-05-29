# frozen_string_literal: true

RSpec.describe Broadcasts::ScanResults::UpdateService do
  subject(:service) { described_class.call(user_id: user_id) }

  shared_examples 'does not broadcasts the message' do
    it { is_expected.to be_falsey }

    it 'does not broadcasts the message' do
      expect { service }.not_to have_broadcasted_to.from_channel(ScanResultChannel)
    end
  end

  describe 'Success' do
    let(:user) { create(:user) }
    let(:user_id) { user.id }

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect { service }.to have_broadcasted_to(user).from_channel(ScanResultChannel).with(nil)
    end
  end

  describe 'Failure' do
    context 'without user_id' do
      let(:user_id) { nil }

      include_examples 'does not broadcasts the message'
    end

    context 'when user is not found' do
      let(:user_id) { 0 }

      include_examples 'does not broadcasts the message'
    end
  end
end
