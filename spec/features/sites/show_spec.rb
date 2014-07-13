include Warden::Test::Helpers
Warden.test_mode!

# Feature: Site page
#   As a user
#   I want to visit a site
#   So I can see a site
feature 'Site page', :devise do

    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site, host: 'fff.com' }

    after(:each) do
        Warden.test_reset!
    end

    # Scenario: User sees own site
    #   Given I am signed in
    #   When I visit one of my sites
    #   Then I see the protocol, host and port
    scenario 'user sees the scan details' do
        user.sites << site

        login_as user, scope: :user
        visit site_path( site )

        expect(page).to have_content site.protocol
        expect(page).to have_content site.host
        expect(page).to have_content site.port
    end

    feature 'when the site is' do
        feature 'verified' do
            # Scenario: User sees 'Verified' when the site is verified
            #   Given I am signed in
            #   When I visit one of my sites
            #   And the site is verified
            #   Then I see 'Verified'
            scenario 'user sees it' do
                user.sites << site
                site.verification.verified!

                login_as user, scope: :user
                visit site_path( site )

                expect(page).to have_content 'Verified'
            end
        end

        feature 'verified' do
            # Scenario: User sees 'Unverified' when the site is verified
            #   Given I am signed in
            #   When I visit one of my sites
            #   And the site is verified
            #   Then I see 'Unverified'
            scenario 'user sees it' do
                user.sites << site

                login_as user, scope: :user
                visit site_path( site )

                expect(page).to have_content 'Unverified'
            end
        end
    end

    # Scenario: User can see an shared site
    #   Given I am signed in
    #   When I try to see a shared site
    #   Then I see the protocol, host and port
    scenario "user cannot cannot see another user's site" do
        user.shared_sites << site

        login_as user, scope: :user

        expect { visit site_path( site ) }.to raise_error ActionController::RoutingError
    end

    # Scenario: User cannot see an unassociated site
    #   Given I am signed in
    #   When I try to see an unassociated site
    #   Then I get a 404 error
    scenario "user cannot cannot see another user's site" do
        user.sites << site

        login_as user, scope: :user

        expect { visit site_path( other_site ) }.to raise_error ActionController::RoutingError
    end

end
