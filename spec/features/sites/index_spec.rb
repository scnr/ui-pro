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

    feature 'owned sites' do
        before do
            other_site.host = 'test.gg'
            user.sites << site
        end

        feature 'which are verified' do
            before do
                site.verification.verified!

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

            # Scenario: Sites which are verified are not accompanied by verification links
            #   Given I am signed in
            #   When I visit the site index page
            #   Then I don't see my verified sites with verification links
            scenario 'user does not see verification link' do
                expect(page).to_not have_xpath "//a[@href='#{verification_site_path( site )}']"
            end

            scenario 'user sees show link' do
                expect(page).to have_xpath "//a[@href='#{site_path( site )}' and not(@data-method)]"
            end

            # Scenario: Sites which are verified are accompanied by edit links
            #   Given I am signed in
            #   When I visit the site index page
            #   Then I see my verified sites with edit links
            scenario 'user can see edit links' do
                expect(page).to have_xpath "//a[@href='#{edit_site_path( site )}']"
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
                        expect(find('.last-scanned')).to have_content 'No scans have been performed yet'
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
                        expect(page).to have_content '17 minutes ago'
                    end

                    feature 'with issues' do
                        before do
                            10.times do
                                type.issues.create( revision: site.revisions.first )
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
        end

        feature 'which are unverified' do
            before do
                site.verification.state = :pending

                login_as( user, scope: :user )
                visit sites_path
            end

            # Scenario: Sites which are unverified are accompanied by verification links
            #   Given I am signed in
            #   When I visit the site index page
            #   Then I see my unverified sites with verification links
            scenario 'user sees verification link' do
                expect(page).to have_xpath "//a[@href='#{verification_site_path( site )}']"
            end

            scenario 'user does not see show link' do
                expect(page).to_not have_xpath "//a[@href='#{site_path( site )}' and not(@data-method)]"
            end

            # Scenario: Sites which are unverified are not accompanied by edit links
            #   Given I am signed in
            #   When I visit the site index page
            #   Then I see my unverified sites without edit links
            scenario 'user does not see edit links' do
                expect(page).to_not have_content edit_site_path(site)
            end

            # Scenario: Sites which are unverified are accompanied by delete links
            #   Given I am signed in
            #   When I visit the site index page
            #   Then I see my unverified sites with delete links
            scenario 'user sees delete links' do
                expect(page).to have_xpath "//a[@href='#{site_path( site )}' and @data-method='delete']"
            end

            feature 'with verification' do
                before do
                    site.verification.state = state
                    site.verification.save

                    visit sites_path
                end

                let(:message) { nil }

                feature 'with message' do
                    let(:state) { :pending }

                    scenario 'user sees the message' do
                        site.verification.message = 'My message'
                        site.verification.save

                        visit sites_path

                        expect(find('.state')).to have_content 'My message'
                    end
                end

                feature :pending do
                    let(:state) { :pending }

                    scenario "user sees 'Pending' state" do
                        expect(find('.state')).to have_content 'Pending'
                    end
                end

                feature :started do
                    let(:state) { :started }

                    scenario "user sees 'In progress' state" do
                        expect(find('.state')).to have_content 'In progress'
                    end
                end

                feature :error do
                    let(:state) { :error }

                    scenario "user sees 'Error' state" do
                        expect(find('.state')).to have_content 'Error'
                    end
                end

                feature :failed do
                    let(:state) { :failed }

                    scenario "user sees 'Failed' state" do
                        expect(find('.state')).to have_content 'Failed'
                    end
                end
            end
        end
    end

    feature 'shared sites' do
        feature 'empty' do
            before do
                login_as( user, scope: :user )
                visit sites_path
            end

            # Scenario: Empty shared sites not listed on index page
            #   Given I am signed in
            #   When I visit the site index page
            #   And there are no shared sites
            #   Then I see no shared sites
            scenario 'user sees no list' do
                expect(page).to_not have_css('#shared-sites')
            end
        end

        feature 'any' do
            before do
                other_site.host = 'test.gg'
                user.shared_sites << site

                login_as( user, scope: :user )
            end

            feature 'verified' do
                before do
                    site.verification.verified!
                    visit sites_path
                end

                scenario 'user sees list' do
                    expect(page).to have_css('#shared-sites')
                    expect(page).to have_content site.url
                end

                scenario 'user does not see edit link' do
                    expect(page).to_not have_xpath "//a[@href='#{edit_site_path(site)}']"
                end

                scenario 'user does not see delete link' do
                    expect(page).to_not have_content 'Delete'
                end
            end

            feature 'verified' do
                before do
                    visit sites_path
                end

                scenario 'user does not see list' do
                    expect(page).to_not have_css('#shared-sites')
                end
            end
        end
    end
end
