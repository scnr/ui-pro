shared_examples_for 'Scan info' do |options = {}|
    let(:scan_info) { super() }
    let(:scan) { super() }

    def scan_info_refresh
        visit current_url
    end

    scenario 'links to the profile' do
        expect(scan_info).to have_xpath "a[@href='#{profile_path( scan.profile )}']"
    end

    scenario 'links to the user agent' do
        expect(scan_info).to have_xpath "a[@href='#{device_path( scan.device )}']"
    end

    scenario 'links to the site role' do
        expect(scan_info).to have_xpath "a[@href='#{site_role_path( site, scan.site_role )}']"
    end

    if options[:hide_schedule]
        feature 'when hiding the schedule' do
            scenario 'is does not show schedule info' do
                expect(scan_info).to_not have_css '.schedule-info'
            end
        end
    else
        let(:schedule_info) { scan_info.find '.schedule-info' }

        feature 'when the schedule' do
            feature 'has a #start_at' do
                before do
                    scan.schedule.start_at = start_at
                    scan.schedule.save

                    scan_info_refresh
                end

                let(:start_at) { Time.now + 1000 }

                scenario 'shows it' do
                    expect(schedule_info).to have_content "runs on #{I18n.l( start_at )}"
                end
            end

            feature 'when the scan is recurring' do
                feature 'with a simple frequency' do
                    before do
                        scan.schedule.day_frequency    = 1
                        scan.schedule.month_frequency  = 2
                        scan.schedule.frequency_format = 'simple'
                        scan.schedule.save

                        scan_info_refresh
                    end

                    scenario 'shows schedule' do
                        expect(schedule_info).to have_content 'every 1 day & 2 months'
                    end
                end

                feature 'with a cronline frequency' do
                    before do
                        scan.schedule.frequency_cron   = '@monthly'
                        scan.schedule.frequency_format = 'cron'
                        scan.schedule.save

                        scan_info_refresh
                    end

                    scenario 'shows schedule' do
                        expect(schedule_info.find('kbd')).to have_content '@monthly'
                    end
                end
            end
        end
    end
end
