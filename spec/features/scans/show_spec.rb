include Warden::Test::Helpers
Warden.test_mode!

# Feature: Scan page
#   As a user
#   I want to visit a scan
#   So I can see the scan revisions
feature 'Scan page' do
    include SiteRolesHelper

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

    let(:info) { find '#scan-info' }

    feature 'when the scan has revisions' do
        before do
            other_revision
            revision
            site.scans << scan
            site.save

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

        feature 'scan info' do
            scenario 'user sees scan name in heading' do
                expect(info.find('h1').text).to include scan.name
            end

            scenario 'user sees scan url in heading' do
                expect(info.find('h1').text).to match scan.url
            end

            feature 'when page filtering is enabled' do
                scenario 'user sees the page URL in the heading'
            end

            scenario 'sees rendered Markdown description' do
                scan.description = '**Stuff**'
                scan.save

                visit site_scan_path( site, scan )

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

            scenario 'user can see edit link' do
                expect(info).to have_xpath "//a[@href='#{edit_site_scan_path(site, scan)}']"
            end

            scenario 'user sees last revision start datetime' do
                expect(info).to have_content "#{revision} started on"
                expect(info).to have_content I18n.l( revision.started_at )
            end

            scenario 'user sees scan duration' do
                expect(info).to have_content Arachni::Utilities.seconds_to_hms( revision.stopped_at - revision.started_at )
            end

            feature 'when the scan is scheduled' do
                before do
                    scan.schedule.start_at = Time.now + 1000
                    scan.schedule.save
                    refresh
                end

                scenario 'user sees schedule' do
                    expect(info).to have_content scan.schedule.to_s
                end
            end

            feature 'which are in progress' do
                before do
                    revision.stopped_at = nil
                    revision.save

                    scan.revisions = [revision]
                    scan.save

                    site.scans << scan
                    site.save

                    visit site_scan_path( site, scan )
                end

                scenario 'user sees progress animation' do
                    expect(info).to have_css 'i.fa.fa-circle-o-notch'
                end

                scenario 'user sees start date' do
                    expect(info).to have_content I18n.l( revision.started_at )
                end
            end

            feature 'which are not in progress' do
                scenario 'user sees last revision stop datetime' do
                    expect(info).to have_content "#{scan.status} on"
                    expect(info).to have_content I18n.l( revision.stopped_at )
                end
            end
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

                scenario 'user sees revision link with filtering options' do
                    expect(revisions).to have_xpath "//a[starts-with(@href, '#{site_scan_revision_path( site, scan, revision )}?filter') and not(@data-method)]"
                end

                feature 'when the revision is in progress' do
                    before do
                        other_revision.stopped_at = nil
                        other_revision.save

                        revision.stopped_at = nil
                        revision.save

                        visit site_scan_path( site, scan )
                    end

                    scenario 'user sees start datetime' do
                        expect(revisions).to have_content 'Started on'
                        expect(revisions).to have_content I18n.l( revision.started_at )
                    end

                    scenario 'user does not sees stop datetime' do
                        expect(revisions).to_not have_content 'Performed on'
                    end
                end

                feature 'when the revision has been performed' do
                    scenario 'user sees stop datetime' do
                        expect(revisions).to have_content 'Performed on'
                        expect(revisions).to have_content I18n.l( revision.performed_at )
                    end
                end
            end
        end
    end

    feature 'when the scan has no revisions' do
        before do
            scan.revisions = []
            scan.save

            visit site_scan_path( site, scan )
        end

        scenario 'user does not see time info' do
            expect(info).to_not have_css '#scan-info-last-revision-time'
        end
    end
end
