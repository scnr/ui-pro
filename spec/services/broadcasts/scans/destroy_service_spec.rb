# frozen_string_literal: true

RSpec.describe Broadcasts::Scans::DestroyService do
  subject(:service) { described_class.call(scan_id: scan_id, user_id: user_id) }

  let(:user) { create(:user) }

  shared_examples 'does not broadcast the message' do
    it { is_expected.to be_falsey }

    it 'does not broadcast the message' do
      expect(ScanChannel).not_to receive(:broadcast_to)
      service
    end
  end

  describe 'Success' do
    let(:scan_id) { rand(1..3) }
    let(:user_id) { user.id }
    let(:channel_params) do
      {
        scan_id: scan_id,
        action: :destroy
      }
    end

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect(ScanChannel).to receive(:broadcast_to).with(user, **channel_params)
      service
    end
  end

  describe 'Failure' do
    context 'when scan_id is not present' do
      let(:scan_id) { nil }
      let(:user_id) { user.id }

      include_examples 'does not broadcast the message'
    end

    context 'when user_id is not present' do
      let(:scan_id) { rand(1..3) }
      let(:user_id) { nil }

      include_examples 'does not broadcast the message'
    end

    context 'when user is not found' do
      let(:scan_id) { rand(1..3) }
      let(:user_id) { 0 }

      include_examples 'does not broadcast the message'
    end
  end
end
