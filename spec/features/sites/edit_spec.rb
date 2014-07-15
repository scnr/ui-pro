include Warden::Test::Helpers
Warden.test_mode!

# Feature: Site edit page
#   As a user
#   I want to edit a site
feature 'Site edit', :devise do

    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site, host: 'fff.com' }

    after(:each) do
        Warden.test_reset!
    end

    scenario 'user can invite other users to collaborate'

    feature 'unverified site' do
        feature 'with owned site' do
            before do
                user.sites << site
                login_as user, scope: :user

                visit edit_site_path( site )
            end

            # Scenario: User cannot edit a shared site
            #   Given I am signed in
            #   When I try to edit a shared site
            #   Then I get a 404 error
            scenario 'user sees "Access denied" message' do
                expect(page).to have_content 'Access denied'
            end
        end

        feature 'with shared site' do
            before do
                user.shared_sites << site
                login_as user, scope: :user

                visit edit_site_path( site )
            end

            # Scenario: User cannot edit a shared unverified site
            #   Given I am signed in
            #   When I try to edit an unverified shared site
            #   Then I get an "Access denied" message
            scenario 'user sees "Access denied" message' do
                expect(page).to have_content 'Access denied'
            end
        end

        feature 'with unassociated site' do
            before do
                login_as user, scope: :user
            end

            # Scenario: User cannot edit an not-owned site
            #   Given I am signed in
            #   When I try to edit a site I don't own
            #   Then I get a 404 error
            scenario 'user gets a 404 error' do
                expect { visit edit_site_path( other_site ) }.to raise_error ActionController::RoutingError
            end
        end
    end
end
