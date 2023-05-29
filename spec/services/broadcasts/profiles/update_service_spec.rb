# frozen_string_literal: true

RSpec.describe Broadcasts::Profiles::UpdateService do
  subject(:service) { described_class.call(profile_id: profile_id) }

  shared_examples 'does not broadcast the message' do
    it { is_expected.to be_falsey }

    it 'does not broadcast the message' do
      expect { service }.not_to have_broadcasted_to.from_channel(ProfileChannel)
    end
  end

  describe 'Success' do
    let(:user) { create(:user) }
    let(:profile) { create(:profile, user: user) }
    let(:profile_id) { profile.id }
    let(:channel_params) do
      {
        profile_id: profile_id,
        action: 'update',
        sidebar_html: sidebar_html,
        profile_html: profile_html
      }
    end

    let(:sidebar_partial_params) do
      {
        partial: 'shared/sidebar_scans',
        locals: {
          scans: profile.scans,
          with_site: true,
          with_count: true
        }
      }
    end
    let(:sidebar_html) { Faker::Lorem.word }

    let(:profile_partial_params) do
      {
        partial: 'profiles/row_field',
        locals: { profile: profile }
      }
    end
    let(:profile_html) { Faker::Lorem.word }

    before do
      allow(ProfilesController).to receive(:render).with(**sidebar_partial_params).and_return(sidebar_html)
      allow(ProfilesController).to receive(:render).with(**profile_partial_params).and_return(profile_html)
    end

    it { is_expected.to be_truthy }

    it 'broadcasts the message' do
      expect { service }.to have_broadcasted_to(user).from_channel(ProfileChannel).with(**channel_params)
    end
  end

  describe 'Failure' do
    context 'when profile is not found' do
      let(:profile_id) { 0 }

      include_examples 'does not broadcast the message'
    end

    context 'when user is not present' do
      let(:profile) { create(:profile) }
      let(:profile_id) { profile.id }

      include_examples 'does not broadcast the message'
    end
  end
end
