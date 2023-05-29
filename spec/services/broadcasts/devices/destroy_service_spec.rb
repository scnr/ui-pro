# frozen_string_literal: true

RSpec.describe Broadcasts::Devices::DestroyService do
  subject(:service) { described_class.call(device_id: device_id) }

  describe 'Success' do
    let(:device_id) { rand(1..3) }
    let(:channel_params) do
      {
        device_id: device_id,
        action: :destroy
      }
    end

    it { is_expected.to be_truthy }

    it 'broadcasts to the DeviceChannel' do
      expect(DeviceChannel).to receive(:broadcast_to).with(:devices, **channel_params)
      service
    end
  end

  describe 'Failure' do
    context 'when device_id is not present' do
      let(:device_id) { nil }

      it { is_expected.to be_falsey }
    end
  end
end
