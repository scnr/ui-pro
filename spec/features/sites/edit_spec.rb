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

    # Scenario: User cannot edit an unassociated site
    #   Given I am signed in
    #   When I try to edit an unassociated site
    #   Then I get a 404 error
    scenario "user cannot cannot edit another user's site" do
        user.sites       << site
        other_user.sites << other_site

        login_as user, scope: :user

        expect { visit edit_site_path( other_site ) }.to raise_error ActionController::RoutingError
    end

    # Scenario: User updates the site
    #   Given I am signed in
    #   When I update the site
    #   Then I see a site updated message
    scenario 'user updates the site' do
        user.sites << site

        login_as user, scope: :user
        visit edit_site_path( site )

        fill_in 'Protocol', with: 'https'
        click_button 'Update'

        expect(page).to have_content 'Site was successfully updated.'
    end

    # Scenario: User changes protocol
    #   Given I am signed in
    #   When I change the protocol
    #   Then the protocol gets changed
    scenario 'user changes protocol' do
        user.sites << site

        login_as user, scope: :user
        visit edit_site_path( site )

        fill_in 'Protocol', with: 'https'
        click_button 'Update'

        expect(site.reload.protocol).to eq 'https'
    end

    # Scenario: User changes host
    #   Given I am signed in
    #   When I change the host
    #   Then the protocol gets changed
    scenario 'user changes host' do
        user.sites << site

        login_as user, scope: :user
        visit edit_site_path( site )

        fill_in 'Host', with: 'blah.gr'
        click_button 'Update'

        expect(site.reload.host).to eq 'blah.gr'
    end

    # Scenario: User changes port
    #   Given I am signed in
    #   When I change the port
    #   Then the port gets changed
    scenario 'user changes port' do
        user.sites << site

        login_as user, scope: :user
        visit edit_site_path( site )

        fill_in 'Port', with: 88
        click_button 'Update'

        expect(site.reload.port).to eq 88
    end

end
