include Warden::Test::Helpers
Warden.test_mode!

# Feature: Scan page
#   As a user
#   I want to visit a scan
#   So I can see the scan revisions
feature 'Scan page' do

    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:site) { FactoryGirl.create :site, scans: [scan] }
    let(:scan) { FactoryGirl.create :scan }

    after(:each) do
        Warden.test_reset!
    end

    before do
        site.verification.verified!

        login_as user, scope: :user
        visit edit_site_scan_path( site, scan )
    end

    scenario 'user can disable it'
    scenario 'user can change the schedule'

    scenario 'user sees scan name in heading' do
        expect(find('h1').text).to match scan.name
    end

    scenario 'user sees site url in heading' do
        expect(find('h1').text).to match site.url
    end

    feature 'user is the site owner' do
        scenario 'user sees verification message' do
            name = 'blahblah'

            fill_in 'Name', with: name
            click_button 'Update'

            expect(page).to have_content 'Scan was successfully updated.'
        end

        scenario 'user can change the enabled status' do
            scan.enabled = false
            scan.save

            check 'Enabled'
            click_button 'Update'

            expect(scan.reload).to be_enabled
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
    end

    feature 'user has the shared site' do
        before do
            login_as other_user, scope: :user
            visit edit_site_scan_path( site, scan )
        end

        scenario 'user sees "Access denied" message' do
            expect(page).to have_content "Access denied"
        end

        scenario 'user is redirected to the home page' do
            expect(current_url).to eq root_url
        end
    end
end
