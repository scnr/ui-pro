feature 'Site page Scans tab' do

    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site }
    let(:profile) { FactoryGirl.create :profile }
    let(:other_site) { FactoryGirl.create :site, host: 'fff.com' }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:other_scan) { FactoryGirl.create :scan, site: site, profile: profile, name: 'Blah' }

    before do
        revision
        user.sites << site

        login_as user, scope: :user
        visit site_path( site )
    end

    after(:each) do
        Warden.test_reset!
    end

    before do
        click_link 'Scans'
    end

    feature 'without scans'

    feature 'with scans' do
        before do
            other_scan.revisions.create
            site.scans << other_scan
        end

        feature 'that are active' do
            let(:scans) { find '#scans-active' }

            scenario 'user sees scan name'
            scenario 'user sees scan profile'
            scenario 'user sees scan status'
            scenario 'user sees amount of pages'
            scenario 'user sees amount of issues'
            scenario 'user sees amount of revisions'
            scenario 'user sees pause button'
            scenario 'user sees suspend button'

            scenario 'user sees edit button' do
                expect(scans).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
            end

            scenario 'user sees abort button'
        end

        feature 'that are suspended' do
            let(:scans) { find '#scans-suspended' }

            scenario 'user sees scan name'
            scenario 'user sees scan profile'
            scenario 'user sees amount of pages'
            scenario 'user sees amount of issues'
            scenario 'user sees amount of revisions'
            scenario 'user sees repeat button'
            scenario 'user sees resume button'

            scenario 'user sees edit button' do
                expect(scans).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
            end

            scenario 'user sees delete button' do
                expect(scans).to have_xpath "//a[@href='#{site_scan_path( site, scan )}' and @data-method='delete']"
            end
        end

        feature 'that are finished' do
            let(:scans) { find '#scans-finished' }

            scenario 'user sees scan name'
            scenario 'user sees scan profile'
            scenario 'user sees amount of pages'
            scenario 'user sees amount of issues'
            scenario 'user sees amount of revisions'
            scenario 'user sees repeat button'

            scenario 'user sees edit button' do
                expect(scans).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
            end

            scenario 'user sees delete button' do
                expect(scans).to have_xpath "//a[@href='#{site_scan_path( site, scan )}' and @data-method='delete']"
            end
        end
    end
end
