include Warden::Test::Helpers
Warden.test_mode!

# Feature: Site index page
#   As a user
#   I want to see a list of my sites
feature 'Site index page' do

    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    # Scenario: Site listed on index page
    #   Given I am signed in
    #   When I visit the site index page
    #   Then I see my sites
    scenario 'user sees own sites' do
        other_site.host = 'test.gg'
        user.sites << site

        login_as( user, scope: :user )
        visit sites_path

        expect(page).to have_css('#owned-sites')
        expect(page).to have_content site.url
        expect(page).to_not have_content other_site.url
    end

    # Scenario: Site listed on index page
    #   Given I am signed in
    #   When I visit the site index page
    #   And there are no shares sites
    #   Then I see no shared sites
    scenario 'user sees own sites' do
        login_as( user, scope: :user )
        visit sites_path

        expect(page).to_not have_css('#shared-sites')
    end

    # Scenario: Site listed on index page
    #   Given I am signed in
    #   When I visit the site index page
    #   And there are no shares sites
    #   Then I see no shared sites
    scenario 'user sees own sites' do
        other_site.host = 'test.gg'
        user.shared_sites << site

        login_as( user, scope: :user )
        visit sites_path

        expect(page).to have_css('#shared-sites')
        expect(page).to have_content site.url
    end

end
