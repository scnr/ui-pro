# Feature: Navigation links
#   As a visitor
#   I want to see navigation links
#   So I can find home, sign in, or sign up
feature 'Navigation links', :devise do

    # Scenario: View navigation links
    #   Given I am a visitor
    #   When I visit the home page
    #   And I am logged in
    #   Then I see navigation links
    scenario 'logged in user can view navigation links' do
        login_as FactoryGirl.create(:user)
        visit root_path

        expect(page).to have_content 'Dashboard'
        expect(page).to have_content 'Sites'
        expect(page).to have_content 'Profiles'
        expect(page).to have_content 'Sign out'
        expect(page).to have_content 'Edit account'
    end

    # Scenario: View navigation links
    #   Given I am a visitor
    #   When I visit the home page
    #   And I am not logged in
    #   Then I see navigation links
    scenario 'not logged in user cannot view navigation links' do
        visit root_path

        expect(page).to_not have_css('div.navbar a')
    end

end
