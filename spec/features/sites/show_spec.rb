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
    let(:scan) { FactoryGirl.create :scan }
    let(:other_scan) { FactoryGirl.create :scan, name: 'Blah' }

    after(:each) do
        Warden.test_reset!
    end

    feature 'with unverified site' do
        before { site.verification.failed! }

        feature 'owned by the user' do
            before do
                user.sites << site

                login_as user, scope: :user
                visit site_path( site )
            end

            # Scenario: User sees "Access denied" when trying to access own unverified site
            #   Given I am signed in
            #   When I visit one of my sites
            #   And it is not verified
            #   Then I see "Access denied"
            scenario 'user sees "Access denied" message' do
                expect(page).to have_content 'Access denied'
            end

            # Scenario: User gets redirected to homepage when trying to access own unverified site
            #   Given I am signed in
            #   When I visit one of my sites
            #   And it is not verified
            #   Then I gets redirected back to the homepage
            scenario 'user gets redirected bash to the homepage' do
                expect(current_url).to match root_path
            end
        end
    end

    feature 'with verified site' do
        before { site.verification.verified! }

        feature 'owned by the user' do
            before do
                user.sites << site

                login_as user, scope: :user
                visit site_path( site )
            end

            # Scenario: User sees own verified site
            #   Given I am signed in
            #   When I visit one of my sites
            #   And it is verified
            #   Then I see the site URL in a heading
            scenario 'user sees the site URL as a heading' do
                expect(find('h1').text).to match site.url
            end
        end

        feature 'shared with the user' do
            before do
                user.shared_sites << site
                login_as user, scope: :user

                visit site_path( site )
            end

            # Scenario: User can see a shared site
            #   Given I am signed in
            #   When I try to see a shared site
            #   Then I see the site URL in a heading
            scenario 'user can can see shared site' do
                expect(find('h1').text).to match site.url
            end
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
end
