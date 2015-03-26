include Warden::Test::Helpers
Warden.test_mode!

feature 'Admin index page' do

    let(:user) { FactoryGirl.create :user }

    after(:each) do
        Warden.test_reset!
    end
end
