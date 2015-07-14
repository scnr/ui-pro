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
        scan.revisions.create!

        user.sites << site

        login_as( user, scope: :user )
    end

    let(:schedule) { find( 'table#scans-schedule-frozen tbody tr' ) }

    feature 'when there are frozen scans' do
        before do
            subject.start_at = nil
            subject.save
            refresh
        end

        scenario 'shows name' do
            expect(schedule).to have_content scan.name
        end

        scenario 'shows link to the scan' do
            expect(schedule).to have_xpath "//a[@href='#{site_scan_path( site, scan )}']"
        end

        scenario 'sets reason' do
            expect(schedule).to have_content 'Missing start date-time'
        end

        scenario 'shows edit button' do
            expect(schedule).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
        end

        feature 'when the scan is suspended' do
            before do
                subject.scan.suspended!
                subject.save
                refresh
            end

            scenario 'sets reason' do
                expect(schedule).to have_css 'i.fa.fa-eject'
                expect(schedule).to have_content 'Suspended'
            end

            feature 'when the scan is recurring' do
                before do
                    subject.day_frequency = 1
                    subject.save
                    refresh
                end

                scenario 'sets additional info' do
                    expect(schedule).to have_content 'Restore to re-activate recurring scans'
                end
            end
        end

        feature 'when the scan is in progress' do
            before do
                subject.scan.scanning!
                subject.save
                refresh
            end

            scenario 'sets reason' do
                expect(schedule).to have_css 'i.fa.fa-spin.fa-circle-o-notch'
                expect(schedule).to have_content 'In progress'
            end

            feature 'when the scan is recurring' do
                before do
                    subject.day_frequency = 1
                    subject.save
                    refresh
                end

                scenario 'sets additional info' do
                    expect(schedule).to have_content 'Recurring scheduling will be re-activated once the scan finishes'
                end
            end
        end

        feature 'when the scan is recurring' do
            before do
                subject.day_frequency = 1
                subject.save
                refresh
            end

            scenario 'sets reason' do
                expect(schedule).to have_content 'Configured to be recurring but missing the start date-time'
            end
        end
    end

    feature 'when there are no frozen scans' do
        before do
            subject.start_at = Time.now
            subject.save
            refresh
        end

        scenario 'shows message' do
            expect(find(:css, '#site-scans-schedule-frozen').find(:css, 'p.alert.alert-info')).to have_content 'No frozen schedules.'
        end
    end

end
