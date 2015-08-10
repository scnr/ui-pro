include Warden::Test::Helpers
Warden.test_mode!

# Feature: Edit scan page
#   As a user
#   I want to edit a scan
#   So I can change its options
feature 'Edit scan page' do

    let(:user) { FactoryGirl.create :user, sites: [site], profiles: [other_profile, profile] }
    let(:site) { FactoryGirl.create :site }
    let(:scan) do
        FactoryGirl.create :scan, profile: profile, site: site,
                           schedule: FactoryGirl.create(:schedule), site_role: site_role
    end
    let(:revision) do
        FactoryGirl.create :revision, scan: scan
    end
    let(:site_role) { FactoryGirl.create :site_role, name: 'Stuff', site: site }
    let(:other_site_role) { FactoryGirl.create :site_role, name: 'Other stuff', site: site }
    let(:profile) { FactoryGirl.create :profile, name: 'Stuff' }
    let(:other_profile) { FactoryGirl.create :profile, name: 'Other stuff' }
    let(:user_agent) { FactoryGirl.create :user_agent }
    let(:other_user_agent) { FactoryGirl.create :user_agent }

    let(:name) { 'name blahblah' }
    let(:description) { 'description blahblah' }

    after(:each) do
        Warden.test_reset!
    end

    def refresh
        visit edit_site_scan_path( site, scan )
    end

    before do
        site_role
        user_agent
        login_as user, scope: :user
        refresh
    end

    let(:site_sidebar_selected_button) { "a[@href='#{site_scans_path(site)}']" }
    it_behaves_like 'Scan sidebar'
    it_behaves_like 'Revisions sidebar'

    scenario 'has title' do
        expect(page).to have_title 'Edit'
        expect(page).to have_title scan.name
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

        expect(breadcrumbs.find('li:nth-of-type(4)')).to have_content 'Scans'
        expect(breadcrumbs.find('li:nth-of-type(4) a').native['href']).to eq site_scans_path( site )

        expect(breadcrumbs.find('li:nth-of-type(5)')).to have_content scan.name
        expect(breadcrumbs.find('li:nth-of-type(5) a').native['href']).to eq site_scan_path( site, scan )

        expect(breadcrumbs.find('li:nth-of-type(6)')).to have_content 'Edit'
        expect(breadcrumbs.find('li:nth-of-type(6) a').native['href']).to eq edit_site_scan_path( site, scan )
    end

    scenario 'user sees scan name in heading' do
        expect(find('h1').text).to match scan.name
    end

    scenario 'user can change the schedule' do
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

        select 'stop', from: 'scan_schedule_attributes_frequency_base'

        click_button 'Update'

        expect(page).to have_content 'Scan was successfully updated.'

        scan = site.scans.last.reload

        expect(scan.name).to eq name
        expect(scan.description).to eq description
        expect(scan.user_agent).to eq user_agent
        expect(scan.site_role).to eq site_role
        expect(scan.profile).to eq profile

        schedule = scan.schedule

        expect(schedule.start_at.to_s).to eq '2016-11-15 21:50:00 UTC'
        expect(schedule.stop_after_hours).to eq 1.5
        expect(schedule.day_frequency).to eq 10
        expect(schedule.month_frequency).to eq 11
        expect(schedule.stop_suspend).to be_truthy
        expect(schedule.frequency_base).to eq 'stop'

        expect(scan).to be_scheduled
    end

    scenario 'user sees verification message' do
        fill_in 'scan_name', with: name
        click_button 'Update'

        expect(page).to have_content 'Scan was successfully updated.'
    end

    scenario 'user can change the name' do
        fill_in 'scan_name', with: name
        click_button 'Update'

        expect(scan.reload.name).to eq name
    end

    scenario 'user can change the description' do
        fill_in 'scan_description', with: description
        click_button 'Update'

        expect(scan.reload.description).to eq description
    end

    scenario 'user can change the profile' do
        select profile.name, from: 'scan_profile_id'
        click_button 'Update'

        expect(scan.reload.profile).to eq profile
    end

    feature 'when the scan has at least one revision' do
        before do
            revision
            refresh
        end

        scenario 'user cannot change the path' do
            expect(page).to have_css '#scan_path.disabled'
        end

        scenario 'user cannot change the profile' do
            expect(page).to have_css '#scan_profile_id.disabled'
        end

        scenario 'user cannot change the site role' do
            expect(page).to have_css '#scan_site_role_id.disabled'
        end

        scenario 'user cannot change the user agent' do
            expect(page).to have_css '#scan_user_agent_id.disabled'
        end
    end

    feature 'when the scan is active' do
        before do
            revision.scanning!
            refresh
        end

        scenario 'user cannot change the start_at' do
            expect(page).to have_css '.scan_schedule_start_at.disabled'
        end
    end

end
