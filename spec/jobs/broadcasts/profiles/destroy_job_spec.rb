# frozen_string_literal: true

RSpec.describe Broadcasts::Profiles::DestroyJob do
  subject(:job) { described_class.perform_later(profile_id, user_id) }

  let(:profile_id) { rand(1..3) }
  let(:user_id) { rand(1..3) }
  let(:queue_name) { 'default' }

  before { allow(Broadcasts::Profiles::DestroyService).to receive(:call).and_return(true) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class).with(profile_id, user_id).on_queue(queue_name)
  end

  describe '.perform' do
    it 'calls Broadcasts::Profiles::DestroyService' do
      expect(Broadcasts::Profiles::DestroyService).to receive(:call).with(profile_id: profile_id, user_id: user_id)
      perform_enqueued_jobs { job }
    end
  end
end
