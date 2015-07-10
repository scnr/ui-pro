include Warden::Test::Helpers
Warden.test_mode!

# Feature: Schedules index page
#   As a user
#   I want to see a full schedule of my scans
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

    let(:schedule) { find( 'table#scans-schedule tbody tr' ) }

    feature 'when there are scheduled scans' do
        scenario 'shows name' do
            expect(schedule).to have_content scan.name
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
                expect(schedule).to have_content 'ASAP'
            end
        end

        feature 'when the scan is suspended' do
            before do
                subject.start_at = nil
                subject.scan.suspended!
                subject.scan.revisions.create!
                subject.save
                refresh
            end

            scenario 'shows that the scan is suspended' do
                expect(schedule).to have_content 'Suspended'
            end
        end

        feature 'when the scan is in progress' do
            before do
                subject.start_at = nil
                subject.save
                refresh
            end

            scenario 'shows spinner' do
                expect(schedule).to have_css 'i.fa.fa-spin.fa-circle-o-notch'
            end
        end

        feature 'when the scan is to be run in the future' do
            before do
                subject.start_at = Time.now + 1000
                subject.save
                refresh
            end

            scenario 'shows the date' do
                expect(schedule).to have_content I18n.l( subject.start_at )
            end
        end

        feature 'when the scan is configured to stop after some time' do
            before do
                subject.stop_after_hours = 10
                subject.save
                refresh
            end

            scenario 'shows it' do
                expect(schedule).to have_content subject.stop_after_hours.to_i.to_s
            end
        end

        feature 'when the scan has a day frequency' do
            before do
                subject.day_frequency = 10
                subject.save
                refresh
            end

            scenario 'shows it' do
                expect(schedule).to have_content "#{subject.day_frequency} days"
            end
        end

        feature 'when the scan has a month frequency' do
            before do
                subject.month_frequency = 10
                subject.save
                refresh
            end

            scenario 'shows it' do
                expect(schedule).to have_content "#{subject.month_frequency} months"
            end
        end
    end

    feature 'when there are no scheduled scans' do
        before do
            scan.schedule.destroy
            scan.save

            refresh
        end

        scenario 'shows message' do
            expect(find(:css, '#site-scans-schedule').find(:css, 'p.alert.alert-info')).to have_content 'No scheduled scans.'
        end
    end

end
