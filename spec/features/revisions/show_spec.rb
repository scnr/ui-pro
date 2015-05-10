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

    let(:info) { find '#revision-info' }

    scenario 'has title' do
        expect(page).to have_title "Revision ##{revision.index}"
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

        expect(breadcrumbs.find('li:nth-of-type(5)')).to have_content "Revision ##{revision.index}"
        expect(breadcrumbs.find('li:nth-of-type(5) a').native['href']).to eq site_scan_revision_path( site, scan, revision )
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

    scenario 'sees rendered Markdown scan description' do
        scan.description = '**Stuff**'
        scan.save

        visit site_scan_revision_path( site, scan, revision )

        expect(find('.description strong')).to have_content 'Stuff'
    end

    scenario 'user sees last revision start datetime' do
        expect(info).to have_content 'Started on'
        expect(info).to have_content I18n.l( revision.started_at )
    end

    scenario 'user sees scan duration' do
        expect(info).to have_content Arachni::Utilities.seconds_to_hms( revision.duration )
    end

    feature 'when the revision has stopped' do
        scenario 'user sees last revision stop datetime' do
            expect(info).to have_content 'stopped on'
            expect(info).to have_content I18n.l( revision.stopped_at )
        end
    end

    feature 'when the revision is in progress' do
        before do
            revision.stopped_at = nil
            revision.save

            visit site_scan_revision_path( site, scan, revision )
        end

        scenario 'user does not sees last revision stop datetime' do
            expect(info).to_not have_content 'stopped on'
        end
    end
end
