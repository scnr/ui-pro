include Warden::Test::Helpers
Warden.test_mode!

# Feature: Revision page
#   As a user
#   I want to review a scan revision
#   So I can see the scan results
feature 'Revision page' do

    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:user_without_sites) { FactoryGirl.create :user, email: 'dd2@ss.cc' }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site, revisions: [revision] }
    let(:revision) { FactoryGirl.create :revision }

    after(:each) do
        Warden.test_reset!
    end

    before do
        site.verification.verified!
    end

    feature 'user is the site owner' do
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

    feature 'user has the shared site' do
        before do
            login_as other_user, scope: :user
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

    feature 'user is not associated with the site' do
        before do
            login_as user_without_sites, scope: :user
            visit site_scan_revision_path( site, scan, revision )
        end

        scenario 'user gets redirected to the homepage' do
            expect(current_url).to eq root_url
        end
    end
end
