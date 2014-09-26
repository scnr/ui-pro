include Warden::Test::Helpers
Warden.test_mode!

# Feature: Scan index
#   As a user
#   I want to see the scans of a site
#   So I can see the site scans
feature 'Scan index' do

    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:other_scan) { FactoryGirl.create :scan, site: site, name: 'Blah', profile: profile }
    let(:profile) { FactoryGirl.create :profile }

    after(:each) do
        Warden.test_reset!
    end

    before do
        site.verification.verified!

        login_as user, scope: :user
        visit site_scans_path( site )
    end

    scenario 'user is redirected to the site page' do
        expect(current_url).to eq url_for( site )
    end

    feature 'when there are no scans' do

        # Scenario: User can see the new scan form when the site has no scans
        #   Given I am signed in
        #   When I visit a site without scans
        #   Then I see the new scan form
        scenario 'user sees a new scan form' do
            expect(page).to have_css 'form#new_scan'
        end
    end

    feature 'when there are scans' do
        before do
            user.sites << site
            site.scans << scan
            site.scans << other_scan

            visit site_path( site )
        end

        # Scenario: User can see a scan list when they visit a site
        #   Given I am signed in
        #   When I visit a site with scans
        #   Then I see a list of scans
        scenario 'user sees a list of scans' do
            expect(page).to have_content scan.name
            expect(page).to have_content other_scan.name
        end

        # Scenario: User can see a scan list when they visit a site
        #   Given I am signed in
        #   When I visit a site with scans
        #   Then I see a list of scans
        scenario 'user sees links to profiles of scans' do
            expect(page).to have_content scan.profile.name
            expect(page).to have_xpath "//a[@href='#{profile_path( scan.profile )}']"

            expect(page).to have_content other_scan.profile.name
            expect(page).to have_xpath "//a[@href='#{profile_path( other_scan.profile )}']"
        end

        # Scenario: User can see links to the scan edit page
        #   Given I am signed in
        #   When I visit a site with scans
        #   Then I see edit links for the listed scans
        scenario 'user sees edit links' do
            expect(page).to have_xpath "//a[@href='#{edit_site_scan_path(scan.site, scan)}']"
            expect(page).to have_xpath "//a[@href='#{edit_site_scan_path(other_scan.site, other_scan)}']"
        end

        # Scenario: User can see links to destroy scans
        #   Given I am signed in
        #   When I visit a site with scans
        #   Then I see destroy links for the listed scans
        scenario 'user sees destroy links' do
            expect(page).to have_xpath "//a[@href='#{site_scan_path(scan.site, scan)}' and @data-method='delete']"
            expect(page).to have_xpath "//a[@href='#{site_scan_path(other_scan.site, other_scan)}' and @data-method='delete']"
        end
    end
end
