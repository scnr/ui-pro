include Warden::Test::Helpers
Warden.test_mode!

# Feature: Scan page
#   As a user
#   I want to visit a scan
#   So I can see the scan revisions
feature 'Scan page' do

    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:site) { FactoryGirl.create :site, scans: [scan] }
    let(:scan) { FactoryGirl.create :scan }

    after(:each) do
        Warden.test_reset!
    end

    before do
        site.verification.verified!

        login_as user, scope: :user
        visit site_scan_path( site, scan )
    end

    scenario 'user sees capitalized scan name in heading' do
        expect(find('h1').text).to match scan.name.capitalize
    end

    scenario 'user sees site url in heading' do
        expect(find('h1').text).to match site.url
    end

    scenario 'user sees scan description' do
        expect(page).to have_content scan.description
    end

    scenario 'user sees profile'
    scenario 'user sees schedule'
    scenario 'user sees revisions'

    feature 'user is the site owner' do
        scenario 'user can see edit link' do
            expect(page).to have_xpath "//a[@href='#{edit_site_scan_path(site, scan)}']"
        end
    end

    feature 'user has the shared site' do
        before do
            login_as other_user, scope: :user
            visit site_scan_path( site, scan )
        end

        scenario 'user cannot see edit link' do
            expect(page).to_not have_xpath "//a[@href='#{edit_site_scan_path(site, scan)}']"
        end
    end
end
