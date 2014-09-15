include Warden::Test::Helpers
Warden.test_mode!

feature 'Admin index page' do

    let(:user) { FactoryGirl.create :user }
    let(:admin) { FactoryGirl.create :user, :admin, email: 'ff@ff.cc' }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'when administrator' do
            before do
                login_as( admin, scope: :user )
                visit admin_root_path
            end

            scenario 'sees the dashboard' do
                expect(current_url).to eq admin_root_url
            end
        end

        feature 'when not an administrator' do
            before do
                login_as( user, scope: :user )
                visit admin_root_path
            end

            scenario 'gets redirected to the homepage' do
                expect(current_url).to eq root_url
            end
        end
    end

    feature 'non authenticated user' do
        scenario 'gets redirected to the sign-in page' do
            visit admin_root_path
            expect(current_url).to eq new_user_session_url
        end
    end
end
