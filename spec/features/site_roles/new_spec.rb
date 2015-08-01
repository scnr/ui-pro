include Warden::Test::Helpers
Warden.test_mode!

feature 'New site role page', js: true do

    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }

    let(:site_role) { FactoryGirl.create :site_role }
    let(:new_role) { site.reload.roles.last }

    after(:each) do
        Warden.test_reset!
    end

    before do
        user.sites << site

        login_as( user, scope: :user )
        visit new_site_role_path( site )
    end

    def submit
        find( '#sidebar button' ).click
        sleep 1
    end

    def fill_in_form
        fill_in 'site_role_name', with: site_role.name
        fill_in 'site_role_description', with: site_role.description

        fill_in 'site_role_session_check_url', with: site_role.session_check_url
        fill_in 'site_role_session_check_pattern', with: site_role.session_check_pattern

        fill_in 'site_role_scope_exclude_path_patterns',
                with: site_role.scope_exclude_path_patterns.join( "\n" )
    end

    def fill_in_form_login_form
        click_link 'Form'

        fill_in 'site_role_login_form_url', with: site_role.login_form_url
        fill_in 'site_role_login_form_parameters',
                with: site_role.login_form_parameters.
                          map { |k, v| "#{k}=#{v}" }.join( "\n" )
    end

    def fill_in_form_login_script
        click_link 'Script'

        page.execute_script(<<EOJS
        ace_editor( 'site_role_login_script_code_editor' ).
            setValue( '#{site_role.login_script_code}' )
EOJS
)
    end

    it_behaves_like 'Site sidebar'
    it_behaves_like 'Roles sidebar'

    scenario 'selects sidebar button', js: false do
        btn = find( "#sidebar-site a[@href='#{site_roles_path(site)}']" )
        expect(btn[:class]).to include 'btn-lg'
    end

    scenario 'can create new role' do
        fill_in_form
        fill_in_form_login_form

        submit

        expect(new_role.name).to eq site_role.name
        expect(new_role.description).to eq site_role.description

        expect(new_role.session_check_url).to eq site_role.session_check_url
        expect(new_role.session_check_pattern).to eq site_role.session_check_pattern

        expect(new_role.scope_exclude_path_patterns).to eq site_role.scope_exclude_path_patterns
    end

    feature 'Log-in procedure' do
        feature 'form' do
            scenario 'can set options' do
                fill_in_form
                fill_in_form_login_form

                submit

                expect(new_role.login_form_url).to eq site_role.login_form_url
                expect(new_role.login_form_parameters).to eq site_role.login_form_parameters
            end
        end

        feature 'script' do
            scenario 'can set code' do
                fill_in_form
                fill_in_form_login_script

                submit

                expect(new_role.login_script_code).to eq site_role.login_script_code
            end

            feature 'examples' do
                before do
                    fill_in_form
                    click_link 'Script'
                end

                feature 'Browser driver' do
                    before do
                        click_link 'Browser driver'
                    end

                    let(:modal) { find '#login-script-browser' }

                    scenario 'can see modal' do
                        expect(modal).to be_visible
                    end

                    scenario 'can use example code' do
                        click_button 'Use example'
                        submit

                        expect(new_role.login_script_code).to include 'browser.goto'
                    end
                end

                feature 'HTTP client' do
                    before do
                        click_link 'HTTP client'
                    end

                    let(:modal) { find '#login-script-http' }

                    scenario 'can see modal' do
                        expect(modal).to be_visible
                    end

                    scenario 'can use example code' do
                        click_button 'Use example'
                        submit

                        expect(new_role.login_script_code).to include 'http.post'
                    end
                end
            end
        end
    end

end
