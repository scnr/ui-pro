feature 'Site page Scans tab' do

    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site }
    let(:profile) { FactoryGirl.create :profile }
    let(:other_site) { FactoryGirl.create :site, host: 'fff.com' }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:other_scan) { new_scan }

    def new_scan
        FactoryGirl.create :scan, site: site, profile: profile
    end

    before do
        revision
        user.sites << site

        login_as user, scope: :user
        visit site_path( site )
        click_link 'Scans'
    end

    after(:each) do
        Warden.test_reset!
    end

    def refresh
        visit current_url
    end

    let(:active) do
        new_scan.tap { |s| s.revisions.create; s.scanning! }
    end

    let(:suspended) do
        new_scan.tap { |s| s.revisions.create; s.suspended! }
    end
    let(:finished) do
        new_scan.tap { |s| s.revisions.create; s.completed! }
    end

    before do
        other_scan.revisions.create
        site.scans << active
        site.scans << suspended
        site.scans << finished

        refresh
    end

    feature 'that are active' do
        let(:scan) { active }
        let(:scans) { find '#site-scans-active' }

        it_behaves_like 'Site scan tables row'

        scenario 'user sees scan status' do
            expect(scans).to have_content scan.status.capitalize
        end

        scenario 'user sees pause button' do
            expect(scans).to have_xpath "//a[@href='#{pause_site_scan_path( site, scan )}' and @data-method='patch']"
        end

        scenario 'user sees suspend button' do
            expect(scans).to have_xpath "//a[@href='#{suspend_site_scan_path( site, scan )}' and @data-method='patch']"
        end

        scenario 'user sees abort button' do
            expect(scans).to have_xpath "//a[@href='#{abort_site_scan_path( site, scan )}' and @data-method='patch']"
        end

        scenario 'user sees edit button' do
            expect(scans).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
        end

        feature 'when the scan is paused' do
            before do
                scan.paused!
                refresh
            end

            scenario 'user does not see pause button' do
                expect(scans).to_not have_xpath "//a[@href='#{pause_site_scan_path( site, scan )}']"
            end

            scenario 'user does not sees suspend button' do
                expect(scans).to_not have_xpath "//a[@href='#{suspend_site_scan_path( site, scan )}']"
            end

            scenario 'user sees resume button' do
                expect(scans).to have_xpath "//a[@href='#{resume_site_scan_path( site, scan )}' and @data-method='patch']"
            end
        end

        feature 'when there are no scans' do
            before do
                scan.completed!
                refresh
            end

            scenario 'shows message' do
                expect(scans.find(:css, 'p.alert.alert-info')).to have_content 'No active scans.'
            end
        end
    end

    feature 'that are suspended' do
        let(:scan) { suspended }
        let(:scans) { find '#site-scans-suspended' }

        it_behaves_like 'Site scan tables row'

        scenario 'user sees scan name' do
            expect(scans).to have_content scan.name
        end

        scenario 'user sees revision' do
            expect(scans).to have_content scan.last_revision.index.ordinalize
        end

        scenario 'user sees scan profile' do
            expect(scans).to have_content scan.profile
        end

        scenario 'user sees amount of pages' do
            expect(scans).to have_content scan.sitemap_entries.size
        end

        scenario 'user sees amount of issues' do
            expect(scans).to have_content scan.issues.size
        end

        scenario 'user sees restore button' do
            expect(scans).to have_xpath "//a[@href='#{restore_site_scan_path( site, scan )}' and @data-method='patch']"
        end

        scenario 'user sees delete button' do
            expect(scans).to have_xpath "//a[@href='#{site_scan_path( site, suspended )}' and @data-method='delete']"
        end

        feature 'when there are no scans' do
            before do
                scan.completed!
                refresh
            end

            scenario 'shows message' do
                expect(scans.find(:css, 'p.alert.alert-info')).to have_content 'No suspended scans.'
            end
        end
    end

    feature 'that are finished' do
        let(:scan) { finished }
        let(:scans) { find '#site-scans-finished' }

        it_behaves_like 'Site scan tables row'

        scenario 'user sees scan status' do
            expect(scans).to have_content scan.status.capitalize
        end

        scenario 'user sees repeat button' do
            expect(scans).to have_xpath "//a[@href='#{repeat_site_scan_path( site, finished )}' and @data-method='post']"
        end

        scenario 'user sees edit button' do
            expect(scans).to have_xpath "//a[@href='#{edit_site_scan_path( site, finished )}']"
        end

        scenario 'user sees delete button' do
            expect(scans).to have_xpath "//a[@href='#{site_scan_path( site, finished )}' and @data-method='delete']"
        end

        feature 'when there are no scans' do
            before do
                scan.scanning!
                refresh
            end

            scenario 'shows message' do
                expect(scans.find(:css, 'p.alert.alert-info')).to have_content 'No finished scans.'
            end
        end
    end
end
