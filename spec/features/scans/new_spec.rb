include Warden::Test::Helpers
Warden.test_mode!

# Feature: New scan page
#   As a user
#   I want to create a scan
feature 'New scan page' do

    let(:user) { FactoryGirl.create :user, sites: [site], profiles: [other_profile, profile] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:site) { FactoryGirl.create :site }
    let(:profile) { FactoryGirl.create :profile, name: 'Stuff' }
    let(:other_profile) { FactoryGirl.create :profile, name: 'Other stuff' }

    let(:name) { 'name blahblah' }
    let(:description) { 'description blahblah' }

    after(:each) do
        Warden.test_reset!
    end

    before do
        login_as user, scope: :user
        visit new_site_scan_path( site )
    end

    scenario 'user sees site url in heading' do
        expect(find('h1').text).to match site.url
    end

    scenario 'user can set the schedule' do
        fill_in 'Name', with: name
        fill_in 'Description', with: description
        select profile.name, from: 'scan_profile_id'

        select '2016', from: 'scan_schedule_attributes_start_at_1i'
        select 'November', from: 'scan_schedule_attributes_start_at_2i'
        select '15', from: 'scan_schedule_attributes_start_at_3i'
        select '21', from: 'scan_schedule_attributes_start_at_4i'
        select '50', from: 'scan_schedule_attributes_start_at_5i'

        fill_in 'scan_schedule_attributes_stop_after_hours', with: 1.5
        select 10, from: 'scan_schedule_attributes_day_frequency'
        select 11, from: 'scan_schedule_attributes_month_frequency'

        click_button 'Create'

        expect(page).to have_content 'Scan was successfully created.'

        scan = site.scans.last

        expect(scan.name).to eq name
        expect(scan.description).to eq description
        expect(scan.profile).to eq profile

        schedule = scan.schedule

        expect(schedule.start_at.to_s).to eq '2016-11-15 21:50:00 UTC'
        expect(schedule.stop_after_hours).to eq 1.5
        expect(schedule.day_frequency).to eq 10
        expect(schedule.month_frequency).to eq 11

        expect(scan).to be_scheduled
    end

    scenario 'user sees own profiles in select box' do
        FactoryGirl.create :profile, name: 'Other user profile'
        expect(page).to have_select 'scan_profile_id', [profile.name, other_profile.name]
    end

    feature 'when the name is missing' do
        scenario 'user sees an error' do
            click_button 'Create'

            expect(find(:div, '.scan_name.has-error')).to be_truthy
        end
    end

    feature 'when stop_after_hours is not numeric' do
        scenario 'user sees an error' do
            fill_in 'Name', with: name
            fill_in 'scan_schedule_attributes_stop_after_hours', with: 'stuff'

            click_button 'Create'

            expect(find(:div, '.scan_schedule_stop_after_hours.has-error')).to be_truthy
        end
    end

    feature 'when start_at is missing' do
        scenario 'the scan is not scheduled' do
            fill_in 'Name', with: name
            select profile.name, from: 'scan_profile_id'

            click_button 'Create'

            expect(site.scans.last.reload).to_not be_scheduled
        end
    end
end
