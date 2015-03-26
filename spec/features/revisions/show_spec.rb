include Warden::Test::Helpers
Warden.test_mode!

# Feature: Revision page
#   As a user
#   I want to review a scan revision
#   So I can see the scan results
feature 'Revision page' do

    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:revision) { FactoryGirl.create :revision, scan: scan }

    after(:each) do
        Warden.test_reset!
    end

    before do
        login_as user, scope: :user
        visit site_scan_revision_path( site, scan, revision )
    end

    scenario 'user sees the revision index in heading' do
        expect(find('h1').text).to match "##{revision.index}"
    end

    scenario 'user sees the scan name in heading' do
        expect(find('h1').text).to match scan.name
    end

    scenario 'user sees site url in heading' do
        expect(find('h1').text).to match site.url
    end

end
