# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do

    # Scenario: Visit the home page
    #   Given I am a visitor
    #   When I visit the home page
    #   I am redirect to the sign-in page
    scenario 'logged out user is redirected to log-in screen' do
        visit root_path
        expect(current_path).to eq new_user_session_path
    end

    # Scenario: Visit the home page
    #   Given I am a visitor
    #   When I visit the home page
    #   I see my sites
    scenario 'logged in user sees site list' do
        login_as FactoryGirl.create(:user)
        visit root_path

        expect(page).to have_content 'Listing sites'
    end

end
