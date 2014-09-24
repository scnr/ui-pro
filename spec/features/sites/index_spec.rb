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

        # Scenario: Site listed on index page
        #   Given I am signed in
        #   When I visit the site index page
        #   Then I see my sites
        scenario 'user sees a list' do
            login_as( user, scope: :user )
            visit sites_path

            expect(page).to have_css('#owned-sites')
            expect(page).to have_content site.url
            expect(page).to_not have_content other_site.url
        end

        feature 'which are verified' do
            before do
                site.verification.verified!

                login_as( user, scope: :user )
                visit sites_path
            end

            # Scenario: Sites which are verified are not accompanied by verification links
            #   Given I am signed in
            #   When I visit the site index page
            #   Then I don't see my verified sites with verification links
            scenario 'user does not see verification link' do
                expect(page).to_not have_xpath "//a[@href='#{verification_site_path( site )}']"
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
        end

        feature 'which are unverified' do
            before do
                site.verification.failed!

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
