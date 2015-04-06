include Warden::Test::Helpers
Warden.test_mode!

feature 'Edit global settings' do
    subject { FactoryGirl.create :setting }
    let(:user) { FactoryGirl.create :user }
    let(:settings) { Setting.get }

    after(:each) do
        Warden.test_reset!
    end

    def submit
        find( :xpath, "//input[@type='submit']" ).click
    end

    feature 'authenticated user' do
        before do
            subject
            login_as( user, scope: :user )
            visit settings_path
        end

        scenario 'sees profile form' do
            expect(find('.profile-form')).to be_truthy
        end

        scenario 'can submit form using sidebar button', js: true do
            fill_in 'Proxy host', with: 'stuff.com'

            find('#sidebar button').click
            sleep 1

            expect(settings.http_proxy_host).to eq 'stuff.com'
        end

        feature 'option' do
            feature 'HTTP' do
                scenario 'can set Proxy host' do
                    fill_in 'Proxy host', with: 'stuff.com'
                    submit

                    expect(settings.http_proxy_host).to eq 'stuff.com'
                end

                scenario 'can set Proxy port' do
                    fill_in 'Proxy port', with: '8080'
                    submit

                    expect(settings.http_proxy_port).to eq 8080
                end

                scenario 'can set Proxy username' do
                    fill_in 'Proxy username', with: 'blah'
                    submit

                    expect(settings.http_proxy_username).to eq 'blah'
                end

                scenario 'can set Proxy password' do
                    fill_in 'Proxy password', with: 'blah'
                    submit

                    expect(settings.http_proxy_password).to eq 'blah'
                end

                scenario 'can set Request queue size' do
                    fill_in 'Request queue size', with: 20
                    submit

                    expect(settings.http_request_queue_size).to eq 20
                end

                scenario 'can set Request timeout' do
                    fill_in 'Request timeout', with: 2000
                    submit

                    expect(settings.http_request_timeout).to eq 2000
                end

                scenario 'can set Redirect limit' do
                    fill_in 'Redirect limit', with: 10
                    submit

                    expect(settings.http_request_redirect_limit).to eq 10
                end

                scenario 'can set Maximum response size' do
                    fill_in 'Maximum response size', with: 1000
                    submit

                    expect(settings.http_response_max_size).to eq 1000
                end
            end

            feature 'Browser' do
                scenario 'can set Processes' do
                    fill_in 'Processes', with: 10
                    submit

                    expect(settings.browser_cluster_pool_size).to eq 10
                end

                scenario 'can set Time to live' do
                    fill_in 'Time to live', with: 10
                    submit

                    expect(settings.browser_cluster_worker_time_to_live).to eq 10
                end

                scenario 'can set Timeout' do
                    fill_in 'Timeout', with: 10
                    submit

                    expect(settings.browser_cluster_job_timeout).to eq 10
                end
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit settings_path
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
