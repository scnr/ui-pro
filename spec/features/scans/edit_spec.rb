include Warden::Test::Helpers
Warden.test_mode!

# Feature: Edit scan page
#   As a user
#   I want to edit a scan
#   So I can change its options
feature 'Edit scan page' do

    let(:user) { FactoryGirl.create :user, sites: [site], profiles: [other_profile, profile] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:site) { FactoryGirl.create :site, scans: [scan] }
    let(:scan) { FactoryGirl.create :scan, profile: profile }
    let(:profile) { FactoryGirl.create :profile, name: 'Stuff' }
    let(:other_profile) { FactoryGirl.create :profile, name: 'Other stuff' }

    after(:each) do
        Warden.test_reset!
    end

    before do
        site.verification.verified!

        login_as user, scope: :user
        visit edit_site_scan_path( site, scan )
    end

    scenario 'user sees scan name in heading' do
        expect(find('h1').text).to match scan.name
    end

    scenario 'user sees site url in heading' do
        expect(find('h1').text).to match site.url
    end

    feature 'user is the site owner' do
        scenario 'user can change the schedule'

        scenario 'user sees verification message' do
            name = 'blahblah'

            fill_in 'Name', with: name
            click_button 'Update'

            expect(page).to have_content 'Scan was successfully updated.'
        end

        scenario 'user can change the name' do
            name = 'blahblah'

            fill_in 'Name', with: name
            click_button 'Update'

            expect(scan.reload.name).to eq name
        end

        scenario 'user can change the description' do
            description = 'blahblah'

            fill_in 'Description', with: description
            click_button 'Update'

            expect(scan.reload.description).to eq description
        end

        scenario 'user can change the profile' do
            select profile.name, from: 'Profile'
            click_button 'Update'

            expect(scan.reload.profile).to eq profile
        end

        feature 'when the scan has at least one revision' do
            scenario 'user cannot change the profile'
        end
    end

    feature 'user has the shared site' do
        before do
            login_as other_user, scope: :user
            visit edit_site_scan_path( site, scan )
        end

        scenario 'user sees "Access denied" message' do
            expect(page).to have_content 'Access denied'
        end

        scenario 'user is redirected to the home page' do
            expect(current_url).to eq root_url
        end
    end
end
