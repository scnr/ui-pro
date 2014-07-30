include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile copy page
#   As a user
#   I want to copy a profile
feature 'Profile copy page', :devise do

    subject { FactoryGirl.create :profile, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'visits copy page' do
            before do
                user.profiles << subject

                login_as( user, scope: :user )
                visit copy_profile_path( subject )
            end

            scenario 'sees the profile form pre-filled' do
                expect(find(:input, '#profile_name').value).to eq subject.name
            end

            scenario 'creates a new profile' do
                name = 'New name here'

                fill_in 'profile_name', with: name
                click_button 'Create'

                expect(Profile.all.last.name).to eq name
            end
        end

        feature 'visits non-owned profile' do
            before do
                user.profiles << subject
                login_as( other_user, scope: :user )
            end

            scenario 'gets a 404 error' do
                expect do
                    visit edit_profile_path( subject )
                end.to raise_error ActionController::RoutingError
            end
        end
    end

    feature 'non authenticated user' do
        before do
            visit edit_profile_path( subject )
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
