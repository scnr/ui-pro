# Feature: Sign out
#   As a user
#   I want to sign out
#   So I can protect my account from unauthorized access
feature 'Sign out', :devise do

    # Scenario: User signs out successfully
    #   Given I am signed in
    #   When I sign out
    #   I am redirected to the sign-in page
    scenario 'user signs out successfully' do
        user = FactoryGirl.create(:user)
        signin(user.email, user.password)
        expect(page).to have_content 'Signed in successfully.'
        click_link 'Sign out'

        expect(current_path).to eq new_user_session_path
    end

end
