# frozen_string_literal: true

RSpec.describe Broadcasts::SiteRoles::CreateService do
  subject(:service) { described_class.call(site_role_id: site_role_id) }

  shared_examples 'does not broadcast the message' do
    it { is_expected.to be_falsey }

    it 'does not broadcast the message' do
      expect { service }.not_to have_broadcasted_to.from_channel(ScanChannel)
    end
  end

  describe 'Success' do
    let(:user) { create(:user) }
    let(:site) { create(:site, user: user) }
    let(:site_role) { create(:site_role, site: site) }
    let(:site_role_id) { site_role.id }

    let(:site_role_partial_params) do
      {
        partial: 'table_row',
        locals: { site_role: site_role }
      }
    end
    let(:sidebar_partial_params) do
      {
        partial: 'shared/sidebar_scans',
          locals: {
            scans: site_role.scans,
            scan_details_options: {
              hide_scan_name: true
            }
          }
      }
    end
    let(:channel_params) do
      {
        site_role_id: site_role.id,
        site_role_html: site_role_html,
        sidebar_html: sidebar_html,
        action: 'create'
      }
    end
    let(:site_role_html) { Faker::Lorem.word }
    let(:sidebar_html) { Faker::Lorem.word }

    before do
      allow(SiteRolesController).to receive(:render).with(**site_role_partial_params).and_return(site_role_html)
      allow(SiteRolesController).to receive(:render).with(**sidebar_partial_params).and_return(sidebar_html)
    end

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect { service }.to have_broadcasted_to(user).from_channel(SiteRoleChannel).with(**channel_params)
    end
  end

  describe 'Failure' do
    context 'when site_role_id is not present' do
      let(:site_role_id) { nil }

      include_examples 'does not broadcast the message'
    end

    context 'when site role is not found' do
      let(:site_role_id) { 0 }

      include_examples 'does not broadcast the message'
    end

    context 'when user is not present' do
      let(:site) { create(:site) }
      let(:site_role) { create(:site_role, site: site) }
      let(:site_role_id) { site_role.id }

      include_examples 'does not broadcast the message'
    end
  end
end
