# frozen_string_literal: true

RSpec.describe Broadcasts::Sites::DestroyJob do
  subject(:job) { described_class.perform_later(site_id, user_id) }

  let(:site_id) { rand(1..3) }
  let(:user_id) { rand(1..3) }
  let(:queue_name) { 'default' }

  before { allow(Broadcasts::Sites::DestroyService).to receive(:call).and_return(true) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class).with(site_id, user_id).on_queue(queue_name)
  end

  describe '.perform' do
    it 'calls Broadcasts::Sites::DestroyService' do
      expect(Broadcasts::Sites::DestroyService).to receive(:call).with(site_id: site_id, user_id: user_id)
      perform_enqueued_jobs { job }
    end
  end
end
