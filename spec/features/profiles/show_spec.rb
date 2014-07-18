include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile page
#   As a user
#   I want to visit a site
#   So I can see the profile options
feature 'Profile page', :devise do

    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:profile) { FactoryGirl.create :profile }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'visits own profile' do
            scenario 'sees the profile options'
        end

        feature 'visits non-owned profile' do
            scenario 'gets redirected'
        end
    end

    feature 'non authenticated user' do
        scenario 'gets redirected'
    end
end
