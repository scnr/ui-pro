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

        scenario 'can set a default profile', js: true do
            profile
            other_profile

            user.profiles << other_profile

            visit profiles_path

            expect(profile).to_not be_default

            choose "id_#{profile.id}"
            sleep(2)

            expect(profile.reload).to be_default
            expect(find( "#id_#{profile.id}" )).to be_checked
            expect(find( "#id_#{other_profile.id}" )).to_not be_checked
        end

        feature 'can export profile as' do
            scenario 'JSON' do
                find_button('profile-export-button').click
                click_link 'JSON'

                expect(page.body).to eq profile.export( JSON )
            end

            scenario 'YAML' do
                find_button('profile-export-button').click
                click_link 'YAML'

                expect(page.body).to eq profile.export( YAML )
            end

            scenario 'AFR' do
                find_button('profile-export-button').click
                click_link 'AFP (Suitable for the CLI interface.)'

                expect(page.body).to eq profile.to_rpc_options.to_yaml
            end
        end

        feature 'can import profile as' do
            let(:file) do
                file = Tempfile.new( described_class.to_s )

                serialized = (serializer == :afr ? profile.to_rpc_options.to_yaml :
                    profile.export( serializer ))

                file.write serialized

                file.rewind

                allow(file).to receive(:original_filename) do
                    File.basename( file.path )
                end

                file
            end

            feature 'JSON' do
                let(:serializer) { JSON }

                scenario 'fills in the form' do
                    find(:xpath, "//a[@href='#profile-import']").click
                    find('#profile_file').set file.path
                    click_button 'Import'

                    expect(find('input#profile_name').value).to eq profile.name
                end
            end

            feature 'YAML' do
                let(:serializer) { YAML }

                scenario 'fills in the form' do
                    find(:xpath, "//a[@href='#profile-import']").click
                    find('#profile_file').set file.path
                    click_button 'Import'

                    expect(find('input#profile_name').value).to eq profile.name
                end
            end

            feature 'AFR' do
                let(:serializer) { :afr }

                scenario 'fills in the form' do
                    find(:xpath, "//a[@href='#profile-import']").click
                    find('#profile_file').set file.path
                    click_button 'Import'

                    expect(find('input#profile_name').value).to eq File.basename( file.path )
                    expect(find('textarea#profile_description').value).to start_with 'Imported from'
                end
            end
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
                expect(page).to have_xpath "//a[@href='#{profile_path( profile )}' and @data-method='delete']"
            end
        end

        feature 'and the profile has scans' do
            before do
                profile.scans << scan

                login_as( user, scope: :user )
                visit profiles_path
            end

            scenario 'cannot edit' do
                expect(find(:xpath, "//a[@href='#{edit_profile_path( profile )}']")[:class]).to include 'disabled'
            end

            scenario 'can copy' do
                expect(page).to have_xpath "//a[@href='#{copy_profile_path( profile )}']"
            end

            # Scenario: Profiles without scan revisions are accompanied by delete links
            #   Given I am signed in
            #   When I visit the profile index page
            #   And the profile has no associated scans with revisions
            #   Then I see profiles with delete links
            scenario 'cannot delete' do
                expect(find(:xpath, "//a[@href='#{profile_path( profile )}' and @data-method='delete']")[:class]).to include 'disabled'
            end

            feature 'when a profile is default' do
                before do
                    profile.default!
                    profile.scans << scan
                    visit profiles_path
                end

                # Scenario: Profiles with scans are not accompanied by delete links
                #   Given I am signed in
                #   When I visit the profile index page
                #   And the profile has associated scans
                #   Then I don't see delete links
                scenario 'cannot delete' do
                    expect(find(:xpath, "//a[@href='#{profile_path( profile )}' and @data-method='delete']")[:class]).to include 'disabled'
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
