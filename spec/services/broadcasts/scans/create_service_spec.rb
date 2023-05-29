# frozen_string_literal: true

RSpec.describe Broadcasts::Scans::CreateService do
  subject(:service) { described_class.call(scan_id: scan_id) }

  shared_examples 'broadcasts the message' do
    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect(ScanChannel).to receive(:broadcast_to).with(user, **channel_params)
      service
    end
  end

  shared_examples 'does not broadcast the message' do
    it { is_expected.to be_falsey }

    it 'does not broadcast the message' do
      expect(ScanChannel).not_to receive(:broadcast_to)
      service
    end
  end

  describe 'Success' do
    let(:user) { create(:user) }
    let(:site) { create(:site, user: user) }
    let(:scan) { create(:scan, status_trait, site: site) }
    let(:scan_id) { scan.id }

    let(:partial_path) { described_class::DEFAULT_TABLE_ROW_PATH }
    let(:scan_partial_params) do
      {
        partial: partial_path,
        locals: {
          scan: scan,
          site: site,
          with_status: with_status
        }
      }
    end
    let(:channel_params) do
      {
        scan_id: scan.id,
        scan_html: scan_html,
        status: status,
        action: :create
      }
    end
    let(:scan_html) { Faker::Lorem.word }
    let(:with_status) { true }

    before do
      allow(ScansController).to receive(:render).with(**scan_partial_params).and_return(scan_html)
    end

    context 'with scheduled status' do
      let(:status_trait) { :with_scheduled_status }
      let(:partial_path) { described_class::SCHEDULED_TABLE_ROW_PATH }
      let(:status) { :scheduled }

      include_examples 'broadcasts the message'
    end

    context 'with suspended status' do
      let(:status_trait) { :with_suspended_status }
      let(:with_status) { false }
      let(:status) { :suspended }

      include_examples 'broadcasts the message'
    end

    context 'with active status' do
      let(:status_trait) { :with_active_status }
      let(:status) { :active }

      include_examples 'broadcasts the message'
    end

    context 'with finished status' do
      let(:status_trait) { :with_finished_status }
      let(:status) { :finished }

      include_examples 'broadcasts the message'
    end
  end

  describe 'Failure' do
    context 'when scan is not found' do
      let(:scan_id) { 0 }

      include_examples 'does not broadcast the message'
    end

    context 'when user is not present' do
      let(:site) { create(:site) }
      let(:scan) { create(:scan, :with_active_status, site: site) }
      let(:scan_id) { scan.id }

      include_examples 'does not broadcast the message'
    end
  end
end
