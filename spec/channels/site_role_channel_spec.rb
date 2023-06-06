# frozen_string_literal: true

RSpec.describe SiteRoleChannel do
  let(:current_user) { create(:user) }

  before do
    stub_connection(current_user: current_user)
    subscribe
  end

  it 'subscribes to a current user stream' do
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(current_user)
  end
end
