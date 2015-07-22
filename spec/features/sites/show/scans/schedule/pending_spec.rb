include Warden::Test::Helpers
Warden.test_mode!

feature 'Schedules index page', js: true do

    subject { scan.schedule }
    let(:scan) { FactoryGirl.create :scan, name: 'Stuff', site: site }
    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site, host: 'gg.gg' }

    after(:each) do
        Warden.test_reset!
    end

    def refresh
        visit "#{site_path( site )}#!/scans"
    end

    before do
        subject
        user.sites << site

        login_as( user, scope: :user )
        visit site_path( site )

        click_link 'Scans'
    end

    let(:schedule) { find( 'table#scans-schedule-pending tbody tr' ) }
    let(:start_at) { schedule.find( '.scans-schedule-pending-start_at' ) }
    let(:stop_after_hours) { schedule.find( '.scans-schedule-pending-stop_after_hours' ) }
    let(:frequency) { schedule.find( '.scans-schedule-pending-frequency' ) }

    feature 'when there are scheduled scans' do
        before do
            scan.schedule.start_at = Time.now + 1000
            scan.save
            refresh
        end

        scenario 'shows name' do
            expect(schedule).to have_content scan.name
        end

        scenario 'shows the date' do
            expect(schedule).to have_content I18n.l( subject.start_at )
        end

        scenario 'shows link to the scan' do
            expect(schedule).to have_xpath "//a[@href='#{site_scan_path( site, scan )}']"
        end

        scenario 'shows edit scan link' do
            expect(schedule).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
        end

        feature 'when the scan is due' do
            before do
                subject.start_at = Time.now
                subject.save
                refresh
            end

            scenario 'shows that the scan is to be run ASAP' do
                expect(start_at.find('span.label.label-info')).to have_content 'ASAP'
            end
        end

        feature 'when the scan is not configured to stop after some time' do
            before do
                subject.stop_after_hours = nil
                subject.save
                refresh
            end

            scenario 'shows it as unrestricted' do
                expect(stop_after_hours.find('span.label.label-info')).to have_content 'Unrestricted'
            end
        end

        feature 'when the scan is configured to stop after some time' do
            before do
                subject.stop_after_hours = 10
                subject.save
                refresh
            end

            scenario 'shows it' do
                expect(stop_after_hours).to have_content subject.stop_after_hours.to_i.to_s
            end
        end

        feature 'when the scan is recurring' do
            feature 'with a simple frequency based on' do
                before do
                    subject.frequency_format = 'simple'
                end

                feature 'day' do
                    before do
                        subject.day_frequency = 10
                        subject.save
                        refresh
                    end

                    scenario 'shows it' do
                        expect(frequency).to have_content "#{subject.day_frequency} days"
                    end
                end

                feature 'month' do
                    before do
                        subject.month_frequency = 10
                        subject.save
                        refresh
                    end

                    scenario 'shows it' do
                        expect(frequency).to have_content "#{subject.month_frequency} months"
                    end
                end
            end

            feature 'when a cron frequency' do
                before do
                    subject.frequency_format = 'cron'
                    subject.frequency_cron   = '@monthly'
                    subject.save
                    refresh
                end

                scenario 'shows it' do
                    expect(frequency.find('kbd')).to have_content subject.frequency_cron
                end
            end
        end

        feature 'when the scan is not recurring' do
            before do
                subject.frequency_format = nil
                subject.save
                refresh
            end

            scenario 'it shows an info label' do
                expect(frequency.find('.label-info')).to have_content 'Unspecified'
            end
        end
    end

    feature 'when there are no scheduled scans' do
        before do
            scan.schedule.start_at = nil
            scan.save
            refresh
        end

        scenario 'shows message' do
            expect(find('#site-scans-schedule-pending p.alert.alert-info')).to have_content 'No pending scans.'
        end
    end

end
