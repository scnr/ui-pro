include Warden::Test::Helpers
Warden.test_mode!

# Feature: Site index page
#   As a user
#   I want to see a list of associated sites
feature 'Site index page' do

    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    feature 'owned sites' do
        # Scenario: Site listed on index page
        #   Given I am signed in
        #   When I visit the site index page
        #   Then I see my sites
        scenario 'user sees a list' do
            other_site.host = 'test.gg'
            user.sites << site

            login_as( user, scope: :user )
            visit sites_path

            expect(page).to have_css('#owned-sites')
            expect(page).to have_content site.url
            expect(page).to_not have_content other_site.url
        end

        # Scenario: Sites are accompanied by verification status
        #   Given I am signed in
        #   When I visit the site index page
        #   Then I see my sites with their verification status
        scenario 'user can see the site verification status' do
            other_site.host = 'test.gg'
            user.sites << site

            site.verification.verified!

            login_as( user, scope: :user )
            visit sites_path

            expect(page).to have_content 'Verified'
        end

        # Scenario: Sites are accompanied by edit links
        #   Given I am signed in
        #   When I visit the site index page
        #   Then I see my sites with edit links
        scenario 'user can edit' do
            other_site.host = 'test.gg'
            user.sites << site

            login_as( user, scope: :user )
            visit sites_path

            click_link 'Edit'

            expect(current_url).to match edit_site_path(site)
        end

        # Scenario: Sites are accompanied by delete links
        #   Given I am signed in
        #   When I visit the site index page
        #   Then I see my sites with delete links
        scenario 'user can delete' do
            other_site.host = 'test.gg'
            user.sites << site

            login_as( user, scope: :user )
            visit sites_path

            click_link 'Delete'

            visit sites_path

            expect(page).to_not have_content site.url
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
                login_as( user, scope: :user )
                visit sites_path

                expect(page).to_not have_css('#shared-sites')
            end
        end

        feature 'any' do
            before do
                other_site.host = 'test.gg'
                user.shared_sites << site

                login_as( user, scope: :user )
                visit sites_path
            end

            # Scenario: Shared site listed on index page
            #   Given I am signed in
            #   When I visit the site index page
            #   And there is a shared site
            #   Then I see it listed
            scenario 'user sees list' do
                other_site.host = 'test.gg'
                user.shared_sites << site

                login_as( user, scope: :user )
                visit sites_path

                expect(page).to have_css('#shared-sites')
                expect(page).to have_content site.url
            end

            # Scenario: Shared sites are not accompanied by edit links
            #   Given I am signed in
            #   When I visit the site index page
            #   Then I see shared sites without edit links
            scenario 'user does not see edit link' do
                other_site.host = 'test.gg'
                user.shared_sites << site

                login_as( user, scope: :user )
                visit sites_path

                expect(page).to_not have_xpath "//a[@href='#{edit_site_path(site)}']"
            end

            # Scenario: Sites are not accompanied by delete links
            #   Given I am signed in
            #   When I visit the site index page
            #   Then I see my sites without delete links
            scenario 'user does not see delete link' do
                expect(page).to_not have_content 'Delete'
            end
        end
    end
end
