include Warden::Test::Helpers
Warden.test_mode!

# Feature: Schedules index page
#   As a user
#   I want to see a full schedule of my scans
feature 'Schedules index page' do

    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site, host: 'gg.gg' }

    after(:each) do
        Warden.test_reset!
    end

    scenario 'users sees their scans in a calendar'
    scenario 'users sees shared scans in a calendar'

end
