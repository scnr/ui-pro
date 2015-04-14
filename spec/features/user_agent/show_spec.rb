include Warden::Test::Helpers
Warden.test_mode!

feature 'User-agent page', :devise do

    subject { FactoryGirl.create :user_agent, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }
    let(:revision) { FactoryGirl.create :revision }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'visits own user_agent' do
            before do
                subject

                login_as( user, scope: :user )
                visit user_agent_path( subject )
            end

            feature 'can export user_agent as' do
                scenario 'JSON' do
                    find_button('user_agent-export-button').click
                    click_link 'JSON'

                    expect(page.body).to eq subject.export( JSON )
                end

                scenario 'YAML' do
                    find_button('user_agent-export-button').click
                    click_link 'YAML'

                    expect(page.body).to eq subject.export( YAML )
                end

                scenario 'AFR' do
                    find_button('user_agent-export-button').click
                    click_link 'AFP (Suitable for the CLI interface.)'

                    expect(page.body).to eq subject.to_rpc_options.to_yaml
                end
            end

            feature 'and the user_agent has no scans' do
                before do
                    subject.scans = []
                    subject.save

                    visit user_agent_path( subject )
                end

                scenario 'can edit' do
                    expect(page).to have_xpath "//a[@href='#{edit_user_agent_path( subject )}']"
                end

                scenario 'can copy' do
                    expect(page).to have_xpath "//a[@href='#{copy_user_agent_path( subject )}']"
                end

                scenario 'can delete' do
                    expect(page).to have_xpath "//a[@href='#{user_agent_path( subject )}' and @data-method='delete']"
                end
            end

            feature 'and the user_agent has scans' do
                feature 'without revisions' do
                    before do
                        subject.scans << scan

                        visit user_agent_path( subject )
                    end

                    scenario 'can edit' do
                        expect(page).to have_xpath "//a[@href='#{edit_user_agent_path( subject )}']"
                    end

                    scenario 'can copy' do
                        expect(page).to have_xpath "//a[@href='#{copy_user_agent_path( subject )}']"
                    end

                    scenario 'cannot delete' do
                        expect(page).to_not have_xpath "//a[@href='#{user_agent_path( subject )}' and @data-method='delete']"
                    end
                end

                feature 'with revisions' do
                    before do
                        scan.revisions << FactoryGirl.create(:revision, scan: scan)
                        subject.scans << scan
                        visit user_agent_path( subject )
                    end

                    scenario 'cannot edit' do
                        expect(page).to_not have_xpath "//a[@href='#{edit_user_agent_path(subject)}']"
                    end

                    scenario 'can copy' do
                        expect(page).to have_xpath "//a[@href='#{copy_user_agent_path( subject )}']"
                    end

                    scenario 'cannot delete' do
                        expect(page).to_not have_xpath "//a[@href='#{user_agent_path( subject )}' and @data-method='delete']"
                    end
                end

                feature 'when a user_agent is default' do
                    before do
                        subject.default!
                        subject.scans << scan
                        visit user_agent_path( subject )
                    end

                    scenario 'cannot delete' do
                        expect(page).to_not have_xpath "//a[@href='#{user_agent_path( subject )}' and @data-method='delete']"
                    end
                end
            end

            scenario 'sees the name in the heading' do
                expect(find('h1')).to have_content subject.name
            end

            scenario 'sees the UA string' do
                expect(find('.lead')).to have_content subject.http_user_agent
            end

            scenario 'sees the resolution' do
                expect(find('.lead')).to have_content "#{subject.browser_cluster_screen_width}x#{subject.browser_cluster_screen_height}"
            end

            scenario 'sees associated scans' do
                subject.scans << scan
                subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

                visit user_agent_path( subject )

                subject.scans.each do |scan|
                    expect(page).to have_content scan.name
                    expect(page).to have_content scan.site.to_s
                end
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit user_agent_path( subject )
        end

        scenario 'gets redirected' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
