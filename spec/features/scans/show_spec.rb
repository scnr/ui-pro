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
    let(:revision) { FactoryGirl.create :revision, scan: scan }

    after(:each) do
        Warden.test_reset!
    end

    before do
        login_as user, scope: :user
        visit site_scan_path( site, scan )
    end

    let(:info) { find '#scan-info' }

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

    scenario 'user can see edit link' do
        expect(page).to have_xpath "//a[@href='#{edit_site_scan_path(site, scan)}']"
    end

    feature 'when the scan is scheduled' do
        scenario 'user sees schedule'
    end

    feature 'when the scan has revisions' do
        before do
            revision
            site.scans << scan
            site.save

            visit site_scan_path( site, scan )
        end

        scenario 'user sees last revision start datetime' do
            expect(info).to have_content I18n.l( revision.started_at )
        end

        scenario 'user sees last revision stop datetime' do
            expect(info).to have_content I18n.l( revision.stopped_at )
        end

        scenario 'user sees scan duration' do
            expect(info).to have_content Arachni::Utilities.seconds_to_hms( revision.stopped_at - revision.started_at )
        end

        feature 'sidebar' do
            let(:sidebar) { find '#sidebar' }

            feature 'revision list' do
                let(:revisions) { find '#scan-sidebar' }

                scenario 'user sees index' do
                    expect(revisions).to have_content "##{revision.index}"
                end

                scenario 'user sees amount of new pages' do
                    expect(revisions).to have_content "#{revision.sitemap_entries.size} new pages"
                end

                scenario 'user sees amount of fixed issues'

                scenario 'user sees amount of new issues'

                scenario 'user sees stop datetime' do
                    expect(revisions).to have_content I18n.l( revision.stopped_at )
                end
            end
        end
    end
end
