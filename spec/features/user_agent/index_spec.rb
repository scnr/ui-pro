include Warden::Test::Helpers
Warden.test_mode!

feature 'User agent index page' do

    let(:user) { FactoryGirl.create :user }
    let(:admin) { FactoryGirl.create :user, :admin, email: 'ff@ff.cc' }
    let(:user_agent) { FactoryGirl.create :user_agent }
    let(:other_user_agent) { FactoryGirl.create :user_agent, name: 'Stuff' }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site }

    after(:each) do
        Warden.test_reset!
    end

    before do
        UserAgent.delete_all
        user_agent
    end

    feature 'authenticated user' do
        before do
            login_as( user, scope: :user )
            visit user_agents_path
        end

        scenario 'has title' do
            expect(page).to have_title 'User agents'
        end

        scenario 'can set a default user agent', js: true do
            user_agent
            other_user_agent

            visit user_agents_path

            expect(user_agent).to_not be_default

            choose "id_#{user_agent.id}"
            sleep(2)

            expect(user_agent.reload).to be_default
            expect(find( "#id_#{user_agent.id}" )).to be_checked
            expect(find( "#id_#{other_user_agent.id}" )).to_not be_checked
        end

        feature 'can export user agent as' do
            scenario 'JSON' do
                find_button('user_agent-export-button').click
                click_link 'JSON'

                expect(page.body).to eq user_agent.export( JSON )
            end

            scenario 'YAML' do
                find_button('user_agent-export-button').click
                click_link 'YAML'

                expect(page.body).to eq user_agent.export( YAML )
            end

            scenario 'AFR' do
                find_button('user_agent-export-button').click
                click_link 'AFP (Suitable for the CLI interface.)'

                expect(page.body).to eq user_agent.to_rpc_options.to_yaml
            end
        end

        feature 'can import user agent as' do
            let(:file) do
                file = Tempfile.new( described_class.to_s )

                serialized = (serializer == :afr ? user_agent.to_rpc_options.to_yaml :
                    user_agent.export( serializer ))

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
                    find(:xpath, "//a[@href='#user_agent-import']").click
                    find('#user_agent_file').set file.path
                    click_button 'Import'

                    expect(find('input#user_agent_name').value).to eq user_agent.name
                end
            end

            feature 'YAML' do
                let(:serializer) { YAML }

                scenario 'fills in the form' do
                    find(:xpath, "//a[@href='#user_agent-import']").click
                    find('#user_agent_file').set file.path
                    click_button 'Import'

                    expect(find('input#user_agent_name').value).to eq user_agent.name
                end
            end

            feature 'AFR' do
                let(:serializer) { :afr }

                scenario 'fills in the form' do
                    find(:xpath, "//a[@href='#user_agent-import']").click
                    find('#user_agent_file').set file.path
                    click_button 'Import'

                    expect(find('input#user_agent_name').value).to eq File.basename( file.path )
                end
            end
        end

        scenario 'sees a list of their user agents' do
            expect(page).to have_content user_agent.name
            expect(page).to_not have_content other_user_agent.name
        end

        scenario 'sees the amount of scans associated with each user agent' do
            user_agent.scans << scan

            login_as( user, scope: :user )
            visit user_agents_path

            expect(page).to have_content user_agent.scans.size
        end

        scenario 'sees a new user agent link' do
            expect(page).to have_xpath "//a[@href='#{new_user_agent_path}']"
        end

        feature 'and the user agent has no scans' do

            scenario 'can edit' do
                expect(page).to have_xpath "//a[@href='#{edit_user_agent_path( user_agent )}']"
            end

            scenario 'can copy' do
                expect(page).to have_xpath "//a[@href='#{copy_user_agent_path( user_agent )}']"
            end

            scenario 'can delete' do
                expect(page).to have_xpath "//a[@href='#{user_agent_path( user_agent )}' and @data-method='delete']"
            end
        end

        feature 'and the user_agent has scans' do
            before do
                user_agent.scans << scan

                login_as( user, scope: :user )
                visit user_agents_path
            end

            scenario 'cannot edit' do
                expect(find(:xpath, "//a[@href='#{edit_user_agent_path( user_agent )}']")[:class]).to include 'disabled'
            end

            scenario 'can copy' do
                expect(page).to have_xpath "//a[@href='#{copy_user_agent_path( user_agent )}']"
            end

            scenario 'cannot delete' do
                expect(find(:xpath, "//a[@href='#{user_agent_path( user_agent )}' and @data-method='delete']")[:class]).to include 'disabled'
            end

            feature 'when a user_agent is default' do
                before do
                    user_agent.default!
                    user_agent.scans << scan
                    visit user_agents_path
                end

                scenario 'cannot delete' do
                    expect(find(:xpath, "//a[@href='#{user_agent_path( user_agent )}' and @data-method='delete']")[:class]).to include 'disabled'
                end
            end
        end
    end

    feature 'non authenticated user' do
        scenario 'gets redirected to the sign-in page' do
            user
            visit user_agents_path
            expect(current_url).to eq new_user_session_url
        end
    end
end
