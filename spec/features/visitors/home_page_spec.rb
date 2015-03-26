# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do

    let(:user) { FactoryGirl.create(:user) }

    context 'when no user has registered' do
        scenario 'user is redirected to sign-up screen' do
            visit root_path
            expect(current_path).to eq new_user_registration_path
        end
    end

    context 'when a user has registered' do
        scenario 'user is redirected to sign-in screen' do
            user
            visit root_path
            expect(current_path).to eq new_user_session_path
        end
    end

    # Scenario: Visit the home page
    #   Given I am a visitor
    #   When I visit the home page
    #   I see my sites
    scenario 'logged in user sees site list' do
        signin user.email, user.password
        visit root_path

        expect(page).to have_content 'Sites'
    end

end
