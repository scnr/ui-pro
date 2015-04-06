include Warden::Test::Helpers
Warden.test_mode!

feature 'User-agent copy page', :devise do

    subject { FactoryGirl.create :user_agent, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    def submit
        find( :xpath, "//input[@type='submit']" ).click
    end

    feature 'authenticated user' do
        feature 'visits copy page' do
            before do
                login_as( user, scope: :user )
                visit copy_user_agent_path( subject )
            end

            scenario 'sees the user-agent form pre-filled' do
                expect(find(:input, '#user_agent_name').value).to eq subject.name
            end

            scenario 'creates a new user-agent' do
                name = 'New name here'

                fill_in 'user_agent_name', with: name
                submit

                expect(UserAgent.last.name).to eq name
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit edit_user_agent_path( subject )
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
