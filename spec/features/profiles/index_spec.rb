include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile index page
#   As a user
#   I want to see a list of my profiles
feature 'Profile index page' do

    let(:user) { FactoryGirl.create :user }
    let(:profile) { FactoryGirl.create :profile }
    let(:other_profile) { FactoryGirl.create :profile, name: 'Stuff' }

    after(:each) do
        Warden.test_reset!
    end

    before do
        other_profile
        user.profiles << profile
    end

    feature 'authenticated user' do
        before do
            login_as( user, scope: :user )
            visit profiles_path
        end

        # Scenario: Profile listed on index page
        #   Given I am signed in
        #   When I visit the profile index page
        #   Then I see my profiles
        scenario 'sees a list of their profiles' do
            expect(page).to have_content profile.name
            expect(page).to_not have_content other_profile.name
        end

        # Scenario: Page contains a "New Profile" link
        #   Given I am signed in
        #   When I visit the profile index page
        #   Then I see a "New Profile" link
        scenario 'sees a new profile link' do
            expect(page).to have_xpath "//a[@href='#{new_profile_path}']"
        end

        # Scenario: Profiles are accompanied by edit links
        #   Given I am signed in
        #   When I visit the profile index page
        #   Then I see my profiles with edit links
        scenario 'can edit' do
            click_link 'Edit'

            expect(current_url).to match edit_profile_path(profile)
        end

        # Scenario: Profiles are accompanied by delete links
        #   Given I am signed in
        #   When I visit the profile index page
        #   Then I see profiles with delete links
        scenario 'can delete' do
            click_link 'Delete'
            visit profiles_path

            expect(page).to_not have_content profile.name
        end
    end

    feature 'non authenticated user' do
        scenario 'gets redirected to the sign-in page' do
            visit profiles_path
            expect(current_url).to eq new_user_session_url
        end
    end
end
