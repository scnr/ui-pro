# frozen_string_literal: true

RSpec.describe Broadcasts::Sites::UpdateService do
  subject(:service) { described_class.call(site_id: site_id) }

  shared_examples 'does not broadcast the message' do
    it { is_expected.to be_falsey }

    it 'does not broadcast the message' do
      expect { service }.not_to have_broadcasted_to.from_channel(SiteChannel)
    end
  end

  describe 'Success' do
    let(:user) { create(:user) }
    let(:site) { create(:site, user: user) }
    let(:site_id) { site.id }

    let(:site_partial_params) do
      {
        partial: 'sites/site',
        locals: { site: site }
      }
    end
    let(:channel_params) do
      {
        site_id: site.id,
        site_html: site_html,
        action: 'update'
      }
    end
    let(:site_html) { Faker::Lorem.word }

    before do
      allow(SitesController).to receive(:render).with(**site_partial_params).and_return(site_html)
    end

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect { service }.to have_broadcasted_to(user).from_channel(SiteChannel).with(**channel_params)
    end
  end

  describe 'Failure' do
    context 'when site_id is not present' do
      let(:site_id) { nil }

      include_examples 'does not broadcast the message'
    end

    context 'when site is not found' do
      let(:site_id) { 0 }

      include_examples 'does not broadcast the message'
    end

    context 'when user is not present' do
      let(:site) { create(:site) }
      let(:site_id) { site.id }

      include_examples 'does not broadcast the message'
    end
  end
end
