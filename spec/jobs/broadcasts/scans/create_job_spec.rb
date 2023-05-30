# frozen_string_literal: true

RSpec.describe Broadcasts::Scans::CreateJob do
  subject(:job) { described_class.perform_later(id) }

  let(:id) { rand(1..3) }
  let(:queue_name) { 'anycable' }

  before { allow(Broadcasts::Scans::CreateService).to receive(:call).and_return(true) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class).with(id).on_queue(queue_name)
  end

  describe '.perform' do
    it 'calls Broadcasts::Scans::CreateService' do
      expect(Broadcasts::Scans::CreateService).to receive(:call).with(scan_id: id)
      perform_enqueued_jobs { job }
    end
  end
end
