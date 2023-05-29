# frozen_string_literal: true

RSpec.describe Broadcasts::Devices::CreateService do
  subject(:service) { described_class.call(device_id: device_id) }

  describe 'Success' do
    let(:device) { create(:device) }
    let(:device_id) { device.id }
    let(:channel_params) do
      {
        device_id: device_id,
        action: 'create',
        sidebar_html: sidebar_html,
        device_html: device_html
      }
    end

    let(:sidebar_partial_params) do
      {
        partial: 'shared/sidebar_scans',
        locals: {
          scans: device.scans,
          with_site: true,
          with_count: true
        }
      }
    end
    let(:sidebar_html) { Faker::Lorem.word }

    let(:device_partial_params) do
      {
        partial: 'devices/row_field',
        locals: { device: device }
      }
    end
    let(:device_html) { Faker::Lorem.word }

    before do
      allow(DevicesController).to receive(:render).with(**sidebar_partial_params).and_return(sidebar_html)
      allow(DevicesController).to receive(:render).with(**device_partial_params).and_return(device_html)
    end

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect { service }.to have_broadcasted_to(:devices).from_channel(DeviceChannel).with(**channel_params)
    end
  end

  describe 'Failure' do
    context 'when device is not found' do
      let(:device_id) { 0 }

      it { is_expected.to be_falsey }

      it 'does not broadcasts the message' do
        expect { service }.not_to have_broadcasted_to.from_channel(DeviceChannel)
      end
    end
  end
end
