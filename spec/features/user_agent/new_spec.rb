include Warden::Test::Helpers
Warden.test_mode!

feature 'User-agent new page' do

    subject { FactoryGirl.create :user_agent, scans: [scan] }
    let(:user) { FactoryGirl.create :user }

    after(:each) do
        Warden.test_reset!
    end

    def submit
        find( :xpath, "//input[@type='submit']" ).click
    end

    feature 'authenticated user' do
        before do
            login_as( user, scope: :user )
            visit new_user_agent_path
        end

        scenario 'sees user_agent form' do
            expect(find('form')).to be_truthy
        end

        feature 'form' do
            before do
                fill_in 'user_agent_name', with: 'My name'
                fill_in 'user_agent_http_user_agent', with: 'My UA'
                fill_in 'user_agent_browser_cluster_screen_width', with: 10
                fill_in 'user_agent_browser_cluster_screen_height', with: 20
            end

            scenario 'can create new user-agent' do
                submit

                ua = UserAgent.last

                expect(ua.name).to eq 'My name'
                expect(ua.http_user_agent).to eq 'My UA'
                expect(ua.browser_cluster_screen_width).to eq 10
                expect(ua.browser_cluster_screen_height).to eq 20
            end

            feature 'Name' do
                scenario 'is mandatory' do
                    fill_in 'user_agent_name', with: ''

                    submit

                    expect(find('.user_agent_name.has-error').text).to include "can't be blank"
                end
            end

            feature 'User-agent' do
                scenario 'is mandatory' do
                    fill_in 'user_agent_http_user_agent', with: ''

                    submit

                    expect(find('.user_agent_http_user_agent.has-error').text).to include "can't be blank"
                end
            end

            feature 'Screen width' do
                scenario 'is mandatory' do
                    fill_in 'user_agent_browser_cluster_screen_width', with: ''

                    submit

                    expect(find('.user_agent_browser_cluster_screen_width.has-error').text).to include "can't be blank"
                end
            end

            feature 'Screen height' do
                scenario 'is mandatory' do
                    fill_in 'user_agent_browser_cluster_screen_height', with: ''

                    submit

                    expect(find('.user_agent_browser_cluster_screen_height.has-error').text).to include "can't be blank"
                end
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit new_user_agent_path
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
