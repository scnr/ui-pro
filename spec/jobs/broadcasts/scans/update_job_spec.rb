# frozen_string_literal: true

RSpec.describe Broadcasts::Scans::UpdateJob do
  subject(:job) { described_class.perform_later(id) }

  let(:id) { rand(1..3) }
  let(:queue_name) { 'default' }

  before { allow(Broadcasts::Scans::UpdateService).to receive(:call).and_return(true) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class).with(id).on_queue(queue_name)
  end

  describe '.perform' do
    it 'calls Broadcasts::Scans::UpdateService' do
      expect(Broadcasts::Scans::UpdateService).to receive(:call).with(scan_id: id)
      perform_enqueued_jobs { job }
    end
  end
end
