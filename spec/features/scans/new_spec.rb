include Warden::Test::Helpers
Warden.test_mode!

# Feature: New scan page
#   As a user
#   I want to create a scan
feature 'New scan page' do
    include ActionView::Helpers::DateHelper

    let(:user) { FactoryGirl.create :user, sites: [site], profiles: [other_profile, profile] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:scan) { FactoryGirl.create :scan, site: site }
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

    feature 'form', js: true do
        let(:schedule_preview) { find '#scan-form-schedule-preview' }

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

        scenario 'user can set the simple frequency' do
            fill_in 'scan_name', with: name

            click_link 'Simple'
            select 10, from: 'scan_schedule_attributes_day_frequency'
            select 11, from: 'scan_schedule_attributes_month_frequency'

            click_button 'Create'

            expect(page).to have_content 'Scan was successfully created.'

            schedule = site.scans.last.schedule

            expect(schedule.day_frequency).to eq 10
            expect(schedule.month_frequency).to eq 11
            expect(schedule.frequency_format).to eq 'simple'
        end

        scenario 'user can set the cron frequency' do
            fill_in 'scan_name', with: name

            click_link 'Cronline'
            fill_in 'scan_schedule_attributes_frequency_cron', with: '@monthly'

            click_button 'Create'

            expect(page).to have_content 'Scan was successfully created.'

            schedule = site.scans.last.schedule

            expect(schedule.frequency_cron).to eq '@monthly'
            expect(schedule.frequency_format).to eq 'cron'
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

            select 'stop', from: 'scan_schedule_attributes_frequency_base'

            check 'Suspend instead of aborting'

            click_button 'Create'

            expect(page).to have_content 'Scan was successfully created.'

            scan = site.scans.last

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
            expect(schedule.frequency_base).to eq 'stop'
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

        feature 'when stop_after_hours is < 0' do
            scenario 'user sees an error' do
                fill_in 'scan_name', with: name
                fill_in 'scan_schedule_attributes_stop_after_hours', with: -1

                click_button 'Create'

                expect(find(:div, '.scan_schedule_stop_after_hours.has-error')).to be_truthy
            end
        end

        feature 'when start_at is' do
            feature 'is set to empty' do
                scenario 'the scan is unscheduled' do
                    fill_in 'scan_name', with: name
                    select site_role.name, from: 'scan_site_role_id'
                    select profile.name, from: 'scan_profile_id'
                    select user_agent.name, from: 'scan_user_agent_id'

                    select '', from: 'scan_schedule_attributes_start_at_1i'
                    select '', from: 'scan_schedule_attributes_start_at_2i'
                    select '', from: 'scan_schedule_attributes_start_at_3i'
                    select '', from: 'scan_schedule_attributes_start_at_4i'
                    select '', from: 'scan_schedule_attributes_start_at_5i'

                    click_button 'Create'
                    sleep 1

                    scan = site.scans.last

                    expect(scan).to_not be_scheduled
                end

                scenario 'shows alert about the scan being unscheduled' do
                    select '', from: 'scan_schedule_attributes_start_at_1i'
                    select '', from: 'scan_schedule_attributes_start_at_2i'
                    select '', from: 'scan_schedule_attributes_start_at_3i'
                    select '', from: 'scan_schedule_attributes_start_at_4i'
                    select '', from: 'scan_schedule_attributes_start_at_5i'

                    sleep 1

                    expect(schedule_preview.find('.alert-warning')).to have_content 'The scan has not been scheduled to run'
                end
            end

            feature 'is not specified' do
                scenario 'the scan is scheduled for now' do
                    fill_in 'scan_name', with: name
                    select site_role.name, from: 'scan_site_role_id'
                    select profile.name, from: 'scan_profile_id'
                    select user_agent.name, from: 'scan_user_agent_id'

                    click_button 'Create'
                    sleep 1

                    scan = site.scans.last

                    expect(scan).to be_scheduled
                    expect(scan).to be_due
                end
            end

            feature 'is specified' do
                before do
                    select start_at.year,             from: 'scan_schedule_attributes_start_at_1i'
                    select start_at.strftime( '%B' ), from: 'scan_schedule_attributes_start_at_2i'
                    select start_at.day,              from: 'scan_schedule_attributes_start_at_3i'
                    select start_at.strftime( '%H' ), from: 'scan_schedule_attributes_start_at_4i'
                    select start_at.strftime( '%M' ), from: 'scan_schedule_attributes_start_at_5i'

                    sleep 1
                end

                let(:start_at) { (Time.now + 1000).utc }
                let(:revision) { schedule_preview.find('#revision-1') }
                let(:nearby_scans) { revision.find '.nearby-scans' }

                scenario 'shows the index of the first revision' do
                    expect(revision).to have_content '1st'
                end

                scenario 'shows the Time distance of the first revision' do
                    expect(revision).to have_content distance_of_time_in_words( Time.now, start_at )
                end

                scenario 'shows the start-at hour' do
                    expect(revision).to have_content start_at.strftime( '%H' )
                end

                scenario 'shows the start-at minute' do
                    expect(revision).to have_content start_at.strftime( '%M' )
                end

                scenario 'shows the start-at day' do
                    expect(revision).to have_content start_at.strftime( '%A' )
                end

                scenario 'shows the start-at day number' do
                    expect(revision).to have_content start_at.day
                end

                scenario 'shows the start-at day month' do
                    expect(revision).to have_content start_at.strftime( '%B' )
                end

                scenario 'shows the start-at day month' do
                    expect(revision).to have_content start_at.year
                end

                context 'when there are other scans with 24 hours' do
                    let(:nearby_scan) do
                        scan.name = 'Nearby scan'
                        scan.schedule.start_at = start_at + 5.hours
                        scan.save
                        scan
                    end

                    before do
                        nearby_scan

                        # Refreshes the schedule preview table.
                        select '01', from: 'scan_schedule_attributes_start_at_5i'
                        select start_at.strftime( '%M' ), from: 'scan_schedule_attributes_start_at_5i'

                        sleep 1
                    end

                    scenario 'lists them' do
                        expect(nearby_scans).to have_content nearby_scan.name
                        expect(nearby_scans).to have_xpath "//a[@href='#{edit_site_scan_path( site, nearby_scan )}']"
                    end

                    scenario 'includes the occurrence of the scan' do
                        expect(nearby_scans).to have_content '1st'
                    end

                    scenario 'includes the time distance' do
                        expect(nearby_scans).to have_content distance_of_time_in_words( start_at, scan.schedule.start_at )
                    end

                    feature 'when the nearby scan has a static schedule' do
                        scenario 'does not show an info tooltip' do
                            expect(nearby_scans).to_not have_xpath "//i[@class='fa fa-info' and @data-toggle='tooltip']"
                        end
                    end

                    feature 'when the nearby scan has a dynamic schedule' do
                        let(:nearby_scan) do
                            s = super()
                            s.schedule.frequency_base = 'stop'
                            s.save
                            s
                        end

                        scenario 'shows an info tooltip' do
                            expect(nearby_scans).to have_xpath "//i[@class='fa fa-info' and @data-toggle='tooltip']"
                        end
                    end
                end

                context 'when there are no scans with 24 hours' do
                    scenario 'shows label' do
                        expect(nearby_scans.find('.label-success')).to have_content 'None'
                    end
                end

                context 'when the cronline is invalid' do
                    before do
                        click_link 'Cronline'
                        fill_in 'scan_schedule_attributes_frequency_cron', with: 'blah'

                        # fill_in doesn't trigger jQuery's onchange.
                        click_link 'Cronline'

                        sleep 1
                    end

                    scenario 'shows error' do
                        expect(schedule_preview.find('.alert-danger')).to have_content 'The cronline is invalid'
                    end
                end
            end
        end
    end
end
