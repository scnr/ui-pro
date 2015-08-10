include Warden::Test::Helpers
Warden.test_mode!

feature 'Scan page' do
    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:other_user) { FactoryGirl.create :user, email: 'dd@ss.cc', shared_sites: [site] }
    let(:site) { FactoryGirl.create :site}
    let(:scan) { FactoryGirl.create :scan, site: site, profile: FactoryGirl.create(:profile) }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:other_revision) { FactoryGirl.create :revision, scan: scan }

    after(:each) do
        Warden.test_reset!
    end

    def refresh
        visit site_scan_path( site, scan )
    end

    before do
        login_as user, scope: :user
        refresh
    end

    let(:site_sidebar_selected_button) { "a[@href='#{site_scans_path(site)}']" }
    it_behaves_like 'Scan sidebar'
    it_behaves_like 'Revisions sidebar'

    let(:with_sitemap_entries) { scan }
    it_behaves_like 'Coverage'

    it_behaves_like 'Issue reviews'

    let(:info) { find '#scan-info' }

    feature 'when the scan has revisions' do
        before do
            other_revision
            revision
            site.scans << scan
            site.save

            refresh
        end

        let(:scan_info) { info.find '.scan-info' }
        it_behaves_like 'Scan info'

        let(:revision_info) { info.find '.revision-info' }
        it_behaves_like 'Revision info', extended: true, hide_scan_name: true

        scenario 'has title' do
            expect(page).to have_title scan.name
            expect(page).to have_title 'Scans'
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

            expect(breadcrumbs.find('li:nth-of-type(4)')).to have_content 'Scans'
            expect(breadcrumbs.find('li:nth-of-type(4) a').native['href']).to eq site_scans_path( site )

            expect(breadcrumbs.find('li:nth-of-type(5)')).to have_content scan.name
            expect(breadcrumbs.find('li:nth-of-type(5) a').native['href']).to eq site_scan_path( site, scan )
        end

        feature 'scan info' do
            scenario 'user sees scan name in heading' do
                expect(info.find('h1').text).to include scan.name
            end

            feature 'when page filtering is enabled' do
                scenario 'user sees the page URL in the heading'
            end

            scenario 'sees rendered Markdown description' do
                scan.description = '**Stuff**'
                scan.save

                refresh

                expect(info.find('.description strong')).to have_content 'Stuff'
            end
        end
    end

    feature 'when the scan has no revisions' do
        before do
            scan.revisions = []
            scan.save

            refresh
        end

        scenario 'user does not see time info' do
            expect(info).to_not have_css '#scan-info-last-revision-time'
        end
    end
end
