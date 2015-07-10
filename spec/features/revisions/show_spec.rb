include Warden::Test::Helpers
Warden.test_mode!

# Feature: Revision page
#   As a user
#   I want to review a scan revision
#   So I can see the scan results
feature 'Revision page' do
    include SiteRolesHelper

    let(:user) { FactoryGirl.create :user, sites: [site] }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:revision) { FactoryGirl.create :revision, scan: scan }

    after(:each) do
        Warden.test_reset!
    end

    def refresh
        visit site_scan_revision_path( site, scan, revision )
    end

    before do
        login_as user, scope: :user
        refresh
    end

    let(:info) { find '#revision-info' }

    scenario 'has title' do
        expect(page).to have_title revision.index.ordinalize
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

        expect(breadcrumbs.find('li:nth-of-type(5)')).to have_content revision.index.ordinalize
        expect(breadcrumbs.find('li:nth-of-type(5) a').native['href']).to eq site_scan_revision_path( site, scan, revision )
    end

    feature 'revision info' do
        scenario 'user sees the revision index in heading' do
            expect(info.find('h1').text).to match revision.index.ordinalize
        end

        scenario 'user sees the scan name in heading' do
            expect(info.find('h1').text).to match scan.name
        end

        scenario 'user sees scan url in heading' do
            expect(info.find('h1').text).to match scan.url
        end

        feature 'when page filtering is enabled' do
            scenario 'user sees the page URL in the heading'
        end

        scenario 'sees rendered Markdown scan description' do
            scan.description = '**Stuff**'
            scan.save

            visit site_scan_revision_path( site, scan, revision )

            expect(info.find('.description strong')).to have_content 'Stuff'
        end

        scenario 'user sees a link to the profile' do
            expect(info).to have_xpath "//a[@href='#{profile_path(scan.profile)}']"
        end

        scenario 'user sees a link to the user agent' do
            expect(info).to have_xpath "//a[@href='#{user_agent_path(scan.user_agent)}']"
        end

        scenario 'user sees a link to the site role' do
            expect(info).to have_xpath "//a[@href='#{site_role_path_js(site, scan.site_role)}']"
        end

        scenario 'user sees last revision start datetime' do
            expect(info).to have_content 'Started on'
            expect(info).to have_content I18n.l( revision.started_at )
        end

        scenario 'user sees scan duration' do
            expect(info).to have_content Arachni::Utilities.seconds_to_hms( revision.duration )
        end

        feature 'when the scan is recurring' do
            before do
                scan.schedule.start_at      = nil
                scan.schedule.day_frequency = 1
                scan.schedule.save
                refresh
            end

            scenario 'user sees schedule' do
                expect(info).to have_content scan.schedule.to_s
            end
        end

        feature 'when the revision has stopped' do
            scenario 'user sees last revision stop datetime' do
                expect(info).to have_content 'stopped on'
                expect(info).to have_content I18n.l( revision.stopped_at )
            end
        end
    end

    feature 'when the revision is in progress' do
        before do
            revision.stopped_at = nil
            revision.save

            visit site_scan_revision_path( site, scan, revision )
        end

        scenario 'user sees progress animation' do
            expect(info).to have_css 'i.fa.fa-circle-o-notch'
        end

        scenario 'user sees start date' do
            expect(info).to have_content I18n.l( revision.started_at )
        end

        scenario 'user does not sees last revision stop datetime' do
            expect(info).to_not have_content 'stopped on'
        end
    end
end
