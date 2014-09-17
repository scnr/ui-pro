include Warden::Test::Helpers
Warden.test_mode!

# Feature: Edit scan page
#   As a user
#   I want to edit a scan
#   So I can change its options
feature 'Edit scan page' do

    let(:user) { FactoryGirl.create :user, sites: [site], profiles: [other_profile, profile] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:site) { FactoryGirl.create :site }
    let(:scan) do
        FactoryGirl.create :scan, profile: profile, site: site, schedule: FactoryGirl.create(:schedule)
    end
    let(:profile) { FactoryGirl.create :profile, name: 'Stuff' }
    let(:other_profile) { FactoryGirl.create :profile, name: 'Other stuff' }

    let(:name) { 'name blahblah' }
    let(:description) { 'description blahblah' }

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

        scenario 'user can change the schedule' do
            fill_in 'Name', with: name
            fill_in 'Description', with: description
            select profile.name, from: 'Profile'

            select '2015', from: 'scan_schedule_attributes_start_at_1i'
            select 'March', from: 'scan_schedule_attributes_start_at_2i'
            select '15', from: 'scan_schedule_attributes_start_at_3i'
            select '21', from: 'scan_schedule_attributes_start_at_4i'
            select '50', from: 'scan_schedule_attributes_start_at_5i'

            fill_in 'Stop after hours', with: 1.5
            fill_in 'scan_schedule_attributes_day_frequency', with: 10
            fill_in 'scan_schedule_attributes_month_frequency', with: 11

            click_button 'Update'

            expect(page).to have_content 'Scan was successfully updated.'

            scan = site.scans.last.reload

            expect(scan.name).to eq name
            expect(scan.description).to eq description
            expect(scan.profile).to eq profile

            schedule = scan.schedule

            expect(schedule.start_at.to_s).to eq '2015-03-15 21:50:00 UTC'
            expect(schedule.stop_after_hours).to eq 1.5
            expect(schedule.day_frequency).to eq 10
            expect(schedule.month_frequency).to eq 11

            expect(scan).to be_scheduled
        end

        scenario 'user sees verification message' do
            fill_in 'Name', with: name
            click_button 'Update'

            expect(page).to have_content 'Scan was successfully updated.'
        end

        scenario 'user can change the name' do
            fill_in 'Name', with: name
            click_button 'Update'

            expect(scan.reload.name).to eq name
        end

        scenario 'user can change the description' do
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
            before do
                site.verification.verified!

                scan.revisions << FactoryGirl.create(:revision)

                login_as user, scope: :user
                visit edit_site_scan_path( site, scan )
            end

            scenario 'user cannot change the profile' do
                expect(page).to have_css '#scan_profile_id.disabled'
            end
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
