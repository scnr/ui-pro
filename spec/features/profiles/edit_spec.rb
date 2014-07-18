include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile edit page
#   As a user
#   I want to edit a profile
#   So I can change its options
feature 'Profile edit page', :devise do

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
