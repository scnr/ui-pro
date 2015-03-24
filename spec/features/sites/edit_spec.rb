include Warden::Test::Helpers
Warden.test_mode!

# Feature: Site edit page
#   As a user
#   I want to edit a site
feature 'Site edit', :devise do

    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site, host: 'fff.com' }

    after(:each) do
        Warden.test_reset!
    end
end
