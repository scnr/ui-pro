include Warden::Test::Helpers
Warden.test_mode!

feature 'Dashboard index page' do

    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site, host: 'gg.gg' }

    after(:each) do
        Warden.test_reset!
    end

    feature 'user sees number of' do
        feature 'unresolved' do
            scenario 'high severity issues'
            scenario 'medium severity issues'
            scenario 'low severity issues'
            scenario 'informational severity issues'
        end
    end

    feature 'user sees latest notifications' do
        scenario 'of own scans'
        scenario 'of shared scans'

        scenario 'of own issues'
        scenario 'of shared issues'
    end

end
