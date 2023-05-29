# frozen_string_literal: true

RSpec.describe Broadcasts::Devices::DestroyService do
  subject(:service) { described_class.call(device_id: device_id) }

  describe 'Success' do
    let(:device_id) { rand(1..3) }
    let(:channel_params) do
      {
        device_id: device_id,
        action: 'destroy'
      }
    end

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect { service }.to have_broadcasted_to(:devices).from_channel(DeviceChannel).with(**channel_params)
    end
  end

  describe 'Failure' do
    context 'when device_id is not present' do
      let(:device_id) { nil }

      it { is_expected.to be_falsey }

      it 'does not broadcasts the message' do
        expect { service }.not_to have_broadcasted_to.from_channel(DeviceChannel)
      end
    end
  end
end
