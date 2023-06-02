# frozen_string_literal: true

RSpec.describe ApplicationCable::Connection do
  let(:env_double) { instance_double('env') }

  before do
    allow_any_instance_of(ApplicationCable::Connection).to receive(:env).and_return(env_double)
    allow(env_double).to receive(:[]).with('warden').and_return(warden)
  end

  describe 'Success' do
    let(:user) { create(:user) }
    let(:warden)  { instance_double('warden', user: user) }

    before { connect('/cable') }

    it 'successfully connects' do
      expect(connection.current_user).to eq(user)
    end
  end

  describe 'Failure' do
    let(:warden)  { instance_double('warden', user: nil) }

    it 'rejects connection' do
      expect { connect('/cable') }.to have_rejected_connection
    end
  end
end
