include Warden::Test::Helpers
Warden.test_mode!

# Feature: New scan page
#   As a user
#   I want to create a scan
feature 'New scan page' do

    let(:user) { FactoryGirl.create :user, sites: [site], profiles: [other_profile, profile] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:site) { FactoryGirl.create :site }
    let(:site_role) { FactoryGirl.create :site_role, name: 'Stuff', site: site }
    let(:other_site_role) { FactoryGirl.create :site_role, name: 'Other stuff', site: site }
    let(:profile) { FactoryGirl.create :profile, name: 'Stuff' }
    let(:other_profile) { FactoryGirl.create :profile, name: 'Other stuff' }
    let(:user_agent) { FactoryGirl.create :user_agent }
    let(:other_user_agent) { FactoryGirl.create :user_agent }

    let(:name) { 'name blahblah' }
    let(:description) { 'description blahblah' }
    let(:path) { 'my-path' }

    after(:each) do
        Warden.test_reset!
    end

    before do
        site_role
        user_agent
        other_user_agent

        login_as user, scope: :user
        visit new_site_scan_path( site )
    end

    scenario 'has title' do
        expect(page).to have_title 'New scan'
        expect(page).to have_title site.url
        expect(page).to have_title 'Sites'
    end

    scenario 'has breadcrumbs' do
        breadcrumbs = find('ul.bread')

        expect(breadcrumbs.find('li:nth-of-type(1) a').native['href']).to eq root_path

        expect(breadcrumbs.find('li:nth-of-type(2)')).to have_content 'Sites'
        expect(breadcrumbs.find('li:nth-of-type(2) a').native['href']).to eq sites_path

        expect(breadcrumbs.find('li:nth-of-type(3)')).to have_content site.url
        expect(breadcrumbs.find('li:nth-of-type(3) a').native['href']).to eq site_path( site )

        expect(breadcrumbs.find('li:nth-of-type(4)')).to have_content 'New scan'
        expect(breadcrumbs.find('li:nth-of-type(4) a').native['href']).to eq new_site_scan_path( site )
    end

    scenario 'user sees site url in heading' do
        expect(find('h1').text).to match site.url
    end

    scenario 'user can set the path' do
        fill_in 'scan_name', with: name
        fill_in 'scan_description', with: description
        fill_in 'scan_path', with: path
        select site_role.name, from: 'scan_site_role_id'
        select profile.name, from: 'scan_profile_id'
        select user_agent.name, from: 'scan_user_agent_id'

        click_button 'Create'

        expect(page).to have_content 'Scan was successfully created.'

        scan = site.scans.last

        expect(scan.name).to eq name
        expect(scan.description).to eq description
        expect(scan.path).to eq "/#{path}"
        expect(scan.user_agent).to eq user_agent
        expect(scan.site_role).to eq site_role
        expect(scan.profile).to eq profile
    end

    scenario 'user can set the schedule' do
        fill_in 'scan_name', with: name
        fill_in 'scan_description', with: description
        select site_role.name, from: 'scan_site_role_id'
        select profile.name, from: 'scan_profile_id'
        select user_agent.name, from: 'scan_user_agent_id'

        select '2016', from: 'scan_schedule_attributes_start_at_1i'
        select 'November', from: 'scan_schedule_attributes_start_at_2i'
        select '15', from: 'scan_schedule_attributes_start_at_3i'
        select '21', from: 'scan_schedule_attributes_start_at_4i'
        select '50', from: 'scan_schedule_attributes_start_at_5i'

        fill_in 'scan_schedule_attributes_stop_after_hours', with: 1.5
        select 10, from: 'scan_schedule_attributes_day_frequency'
        select 11, from: 'scan_schedule_attributes_month_frequency'

        check 'Suspend instead of aborting'
        check 'Mark issues which do not appear in subsequent revisions as fixed'

        click_button 'Create'

        expect(page).to have_content 'Scan was successfully created.'

        scan = site.scans.last

        expect(scan.name).to eq name
        expect(scan.description).to eq description
        expect(scan.user_agent).to eq user_agent
        expect(scan.site_role).to eq site_role
        expect(scan.profile).to eq profile
        expect(scan.mark_missing_issues_fixed).to be_truthy

        schedule = scan.schedule

        expect(schedule.start_at.to_s).to eq '2016-11-15 21:50:00 UTC'
        expect(schedule.stop_after_hours).to eq 1.5
        expect(schedule.day_frequency).to eq 10
        expect(schedule.month_frequency).to eq 11
        expect(schedule.stop_suspend).to be_truthy

        expect(scan).to be_scheduled
    end

    scenario 'user sees own profiles in select box' do
        FactoryGirl.create :profile, name: 'Other user profile'
        visit new_site_scan_path( site )

        expect(page).to have_select 'scan_profile_id', [profile.name, other_profile.name]
    end

    scenario 'user sees user-agents in select box' do
        expect(page).to have_select 'scan_user_agent_id', [user_agent.name, other_user_agent.name]
    end

    feature 'when the name is missing' do
        scenario 'user sees an error' do
            click_button 'Create'

            expect(find(:div, '.scan_name.has-error')).to be_truthy
        end
    end

    feature 'when stop_after_hours is not numeric' do
        scenario 'user sees an error' do
            fill_in 'scan_name', with: name
            fill_in 'scan_schedule_attributes_stop_after_hours', with: 'stuff'

            click_button 'Create'

            expect(find(:div, '.scan_schedule_stop_after_hours.has-error')).to be_truthy
        end
    end

    feature 'when start_at is missing' do
        scenario 'the scan is not scheduled' do
            fill_in 'scan_name', with: name
            select site_role.name, from: 'scan_site_role_id'
            select profile.name, from: 'scan_profile_id'
            select user_agent.name, from: 'scan_user_agent_id'

            click_button 'Create'

            expect(site.scans.last.reload).to_not be_scheduled
        end
    end
end
