# frozen_string_literal: true

RSpec.describe DeviceChannel do
  let(:current_user) { create(:user) }

  before do
    stub_connection(current_user: current_user)
    subscribe
  end

  it 'subscribes to a devices stream' do
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(:devices)
  end
end
