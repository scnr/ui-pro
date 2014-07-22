include Warden::Test::Helpers
Warden.test_mode!

# Feature: New scan page
#   As a user
#   I want to create a scan
feature 'New scan page' do

    let(:user) { FactoryGirl.create :user, sites: [site], profiles: [other_profile, profile] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:site) { FactoryGirl.create :site  }
    let(:profile) { FactoryGirl.create :profile, name: 'Stuff' }
    let(:other_profile) { FactoryGirl.create :profile, name: 'Other stuff' }

    after(:each) do
        Warden.test_reset!
    end

    before do
        site.verification.verified!

        login_as user, scope: :user
        visit new_site_scan_path( site )
    end

    scenario 'user sees site url in heading' do
        expect(find('h1').text).to match site.url
    end

    scenario 'user can set the schedule'

    scenario 'user sees verification message' do
        name        = 'name blahblah'
        description = 'description blahblah'

        fill_in 'Name', with: name
        fill_in 'Description', with: description
        select profile.name, from: 'Profile'

        click_button 'Create'

        expect(page).to have_content 'Scan was successfully created.'

        scan = site.scans.last

        expect(scan.name).to eq name
        expect(scan.description).to eq description
        expect(scan.profile).to eq profile
    end

    scenario 'user sees own profiles in select box' do
        FactoryGirl.create :profile, name: 'Other user profile'
        expect(page).to have_select 'Profile', [profile.name, other_profile.name]
    end
end
