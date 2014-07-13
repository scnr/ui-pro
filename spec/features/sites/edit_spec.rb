include Warden::Test::Helpers
Warden.test_mode!

# Feature: Site edit page
#   As a user
#   I want to edit my site
feature 'Site edit', :devise do

    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site, host: 'fff.com' }

    after(:each) do
        Warden.test_reset!
    end

    # Scenario: User cannot edit an not-owned site
    #   Given I am signed in
    #   When I try to edit a site I don't own
    #   Then I get a 404 error
    scenario "user cannot cannot edit a site they don't own" do
        user.sites << site

        login_as user, scope: :user

        expect { visit edit_site_path( other_site ) }.to raise_error ActionController::RoutingError
    end

    # Scenario: User cannot edit a shared site
    #   Given I am signed in
    #   When I try to edit a shared site
    #   Then I get a 404 error
    scenario 'user cannot cannot edit a shared site' do
        user.shared_sites << site

        login_as user, scope: :user

        expect { visit edit_site_path( site ) }.to raise_error ActionController::RoutingError
    end

    # Scenario: User sees verification button
    #   Given I am signed in
    #   When I go to the edit page
    #   Then I see a verification link
    scenario 'user sees verification link' do
        user.sites << site

        login_as user, scope: :user
        visit edit_site_path( site )

        expect(page).to have_xpath "//a[@href='#{verify_site_path(site)}']"
    end

end
