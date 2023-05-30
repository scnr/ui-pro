# frozen_string_literal: true

RSpec.describe Broadcasts::SiteRoles::DestroyJob do
  subject(:job) { described_class.perform_later(site_role_id, user_id) }

  let(:site_role_id) { rand(1..3) }
  let(:user_id) { rand(1..3) }
  let(:queue_name) { 'anycable' }

  before { allow(Broadcasts::SiteRoles::DestroyService).to receive(:call).and_return(true) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class).with(site_role_id, user_id).on_queue(queue_name)
  end

  describe '.perform' do
    it 'calls Broadcasts::SiteRoles::DestroyService' do
      expect(Broadcasts::SiteRoles::DestroyService).to receive(:call).with(site_role_id: site_role_id, user_id: user_id)
      perform_enqueued_jobs { job }
    end
  end
end
