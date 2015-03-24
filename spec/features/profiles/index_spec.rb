include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile index page
#   As a user
#   I want to see a list of my profiles
feature 'Profile index page' do

    let(:user) { FactoryGirl.create :user }
    let(:admin) { FactoryGirl.create :user, :admin, email: 'ff@ff.cc' }
    let(:profile) { FactoryGirl.create :profile }
    let(:other_profile) { FactoryGirl.create :profile, name: 'Stuff' }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site }

    after(:each) do
        Warden.test_reset!
    end

    before do
        Scan.delete_all
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

        scenario 'sees the amount of scans associated with each profile' do
            profile.scans << scan

            login_as( user, scope: :user )
            visit profiles_path

            expect(page).to have_content profile.scans.size
            expect(page).to_not have_content other_profile.scans.size
        end

        # Scenario: Page contains a "New Profile" link
        #   Given I am signed in
        #   When I visit the profile index page
        #   Then I see a "New Profile" link
        scenario 'sees a new profile link' do
            expect(page).to have_xpath "//a[@href='#{new_profile_path}']"
        end

        feature 'and the profile has no scans' do

            # Scenario: Profiles without scans are accompanied by edit links
            #   Given I am signed in
            #   When I visit the profile index page
            #   And the profile has no associated scans
            #   Then I see my profiles with edit links
            scenario 'can edit' do
                expect(page).to have_xpath "//a[@href='#{edit_profile_path( profile )}']"
            end

            scenario 'can copy' do
                expect(page).to have_xpath "//a[@href='#{copy_profile_path( profile )}']"
            end

            # Scenario: Profiles without scans are accompanied by delete links
            #   Given I am signed in
            #   When I visit the profile index page
            #   And the profile has no associated scans
            #   Then I see profiles with delete links
            scenario 'can delete' do
                click_link 'Delete'
                visit profiles_path

                expect(page).to_not have_content profile.name
            end
        end

        feature 'and the profile has scans' do
            feature 'without revisions' do
                before do
                    profile.scans << scan

                    login_as( user, scope: :user )
                    visit profiles_path
                end

                # Scenario: Profiles without scan revisions are accompanied by edit links
                #   Given I am signed in
                #   When I visit the profile index page
                #   And the profile has no associated scans with revisions
                #   Then I see my profiles with edit links
                scenario 'can edit' do
                    expect(page).to have_xpath "//a[@href='#{edit_profile_path( profile )}']"
                end

                scenario 'can copy' do
                    expect(page).to have_xpath "//a[@href='#{copy_profile_path( profile )}']"
                end

                # Scenario: Profiles without scan revisions are accompanied by delete links
                #   Given I am signed in
                #   When I visit the profile index page
                #   And the profile has no associated scans with revisions
                #   Then I see profiles with delete links
                scenario 'can delete' do
                    click_link 'Delete'
                    visit profiles_path

                    expect(page).to_not have_content profile.name
                end
            end

            feature 'with revisions' do
                before do
                    scan.revisions << FactoryGirl.create(:revision, scan: scan)
                    profile.scans << scan
                    visit profiles_path
                end

                # Scenario: Profiles with scans are not accompanied by edit links
                #   Given I am signed in
                #   When I visit the profile index page
                #   And the profile has associated scans
                #   Then I don't see edit links
                scenario 'cannot edit' do
                    expect(page).to_not have_xpath "//a[@href='#{edit_profile_path(profile)}']"
                end

                scenario 'can copy' do
                    expect(page).to have_xpath "//a[@href='#{copy_profile_path( profile )}']"
                end

                # Scenario: Profiles with scans are not accompanied by delete links
                #   Given I am signed in
                #   When I visit the profile index page
                #   And the profile has associated scans
                #   Then I don't see delete links
                scenario 'cannot delete' do
                    expect(page).to_not have_selector(:link_or_button, 'Delete')
                end
            end
        end
    end

    feature 'non authenticated user' do
        scenario 'gets redirected to the sign-in page' do
            visit profiles_path
            expect(current_url).to eq new_user_session_url
        end
    end
end
