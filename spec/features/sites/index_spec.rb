include Warden::Test::Helpers
Warden.test_mode!

# Feature: Site index page
#   As a user
#   I want to see a list of associated sites
feature 'Site index page' do

    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site, host: 'gg.gg' }

    after(:each) do
        Warden.test_reset!
    end

    before do
        other_site.host = 'test.gg'
        user.sites << site

        login_as( user, scope: :user )
        visit sites_path
    end

    # Scenario: Site listed on index page
    #   Given I am signed in
    #   When I visit the site index page
    #   Then I see my sites
    scenario 'user sees URLs' do
        expect(page).to have_content site.url
        expect(page).to_not have_content other_site.url
    end

    scenario 'user sees show link' do
        expect(page).to have_xpath "//a[@href='#{site_path( site )}' and not(@data-method)]"
    end

    # Scenario: Sites which are verified are accompanied by delete links
    #   Given I am signed in
    #   When I visit the site index page
    #   Then I see my verified sites with delete links
    scenario 'user can delete' do
        expect(page).to have_xpath "//a[@href='#{site_path( site )}' and @data-method='delete']"
    end

    feature 'with scans' do
        before do
            scan
            visit sites_path
        end

        let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
        let(:profile) { FactoryGirl.create :profile }

        feature 'without revisions' do
            scenario 'user sees undetermined last scan time' do
                expect(find('.last-scanned')).to have_content 'never'
            end

            scenario "user sees 'Undetermined' state label" do
                expect(find('span.label-severity-undetermined')).to have_content 'Undetermined'
            end
        end

        feature 'with revisions' do
            before do
                scan.revisions.create(
                    started_at: Time.now - 2000,
                    stopped_at: Time.now - 1000
                )

                visit sites_path
            end

            scenario 'user sees time passed since last revision' do
                expect(page).to have_content '1 hour and 16 minutes ago'
                expect(page).to have_xpath "//a[@href='#{site_scan_revision_path( site, site.revisions.last.scan, site.revisions.last )}']"
            end

            feature 'with issues' do
                before do
                    10.times do
                        type.issues.create(
                            revision: site.revisions.first,
                            state:    'trusted'
                        )
                    end

                    visit sites_path
                end

                let(:type) { FactoryGirl.create( :issue_type, severity: severity ) }

                {
                    high:   'Critical',
                    medium: 'Serious',
                    low:    'Fair'
                }.each do |s, state|
                    feature "with #{s} severity" do
                        let(:severity) { FactoryGirl.create( :issue_type_severity, name: s ) }

                        scenario "user sees '#{state}' state label" do
                            expect(find("span.label-severity-#{s}")).to have_content state
                        end

                        scenario 'user sees number of issues' do
                            expect(find('.state')).to have_content '10'
                        end
                    end
                end

                feature 'with informational severity' do
                    let(:severity) { FactoryGirl.create( :issue_type_severity, name: :informational ) }

                    scenario "user sees 'Good' state label" do
                        expect(find("span.label-severity-informational")).to have_content 'Good'
                    end
                end
            end
        end
    end

    feature 'without scans' do
        before do
            visit sites_path
        end

        scenario 'user does not see the table' do
            expect(page).to_not have_content('#sites')
        end
    end

    scenario 'user can add new site' do
        select 'http', from: 'site[protocol]'
        fill_in 'site[host]', with: 'example.com'
        fill_in 'site[port]', with: 8080
        click_button 'Add'

        expect(page).to have_content 'Site was successfully created.'

        site = Site.last

        expect(site.protocol).to eq 'http'
        expect(site.host).to eq 'example.com'
        expect(site.port).to eq 8080
    end

    scenario 'protocol drop-down updates port', js: true do
        expect(find('#site_port').value).to eq '80'

        select 'https', from: 'site[protocol]'

        expect(find('#site_port').value).to eq '443'
    end
end
