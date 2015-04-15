include Warden::Test::Helpers
Warden.test_mode!

# Feature: Scan page
#   As a user
#   I want to visit a scan
#   So I can see the scan revisions
feature 'Scan page' do

    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:site) { FactoryGirl.create :site}
    let(:scan) { FactoryGirl.create :scan, site: site, profile: FactoryGirl.create(:profile) }

    after(:each) do
        Warden.test_reset!
    end

    before do
        login_as user, scope: :user
        visit site_scan_path( site, scan )
    end

    scenario 'has title' do
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

        expect(breadcrumbs.find('li:nth-of-type(4)')).to have_content scan.name
        expect(breadcrumbs.find('li:nth-of-type(4) a').native['href']).to eq site_scan_path( site, scan )
    end

    scenario 'user sees capitalized scan name in heading' do
        expect(find('h1').text).to match scan.name.capitalize
    end

    scenario 'user sees site url in heading' do
        expect(find('h1').text).to match site.url
    end

    scenario 'sees rendered Markdown description' do
        scan.description = '**Stuff**'
        scan.save

        visit site_scan_path( site, scan )

        expect(find('.description strong')).to have_content 'Stuff'
    end

    scenario 'user sees a link to the profile' do
        expect(page).to have_xpath "//a[@href='#{profile_path(scan.profile)}']"
    end

    scenario 'user sees schedule'

    scenario 'user sees the revisions'

    feature 'user is the site owner' do
        scenario 'user can see edit link' do
            expect(page).to have_xpath "//a[@href='#{edit_site_scan_path(site, scan)}']"
        end
    end
end
