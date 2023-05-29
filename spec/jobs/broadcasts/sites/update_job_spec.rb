# frozen_string_literal: true

RSpec.describe Broadcasts::Sites::UpdateJob do
  subject(:job) { described_class.perform_later(id) }

  let(:id) { rand(1..3) }
  let(:queue_name) { 'default' }

  before { allow(Broadcasts::Sites::UpdateService).to receive(:call).and_return(true) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class).with(id).on_queue(queue_name)
  end

  describe '.perform' do
    it 'calls Broadcasts::Sites::UpdateService' do
      expect(Broadcasts::Sites::UpdateService).to receive(:call).with(site_id: id)
      perform_enqueued_jobs { job }
    end
  end
end
