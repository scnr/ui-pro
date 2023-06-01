# frozen_string_literal: true

RSpec.describe Broadcasts::Scans::DestroyJob do
  subject(:job) { described_class.perform_later(scan_id, user_id) }

  let(:scan_id) { rand(1..3) }
  let(:user_id) { rand(1..3) }
  let(:queue_name) { 'default' }

  before { allow(Broadcasts::Scans::DestroyService).to receive(:call).and_return(true) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class).with(scan_id, user_id).on_queue(queue_name)
  end

  describe '.perform' do
    it 'calls Broadcasts::Scans::DestroyService' do
      expect(Broadcasts::Scans::DestroyService).to receive(:call).with(scan_id: scan_id, user_id: user_id)
      perform_enqueued_jobs { job }
    end
  end
end
