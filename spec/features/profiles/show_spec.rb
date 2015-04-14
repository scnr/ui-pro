include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile page
#   As a user
#   I want to visit a site
#   So I can see the profile options
feature 'Profile page', :devise do

    subject { FactoryGirl.create :profile, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }
    let(:revision) { FactoryGirl.create :revision }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'visits own profile' do
            before do
                user.profiles << subject

                login_as( user, scope: :user )
                visit profile_path( subject )
            end

            feature 'and the profile has scans' do
                before do
                    subject.scans << scan
                    subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )
                    subject.save

                    visit profile_path( subject )
                end

                scenario 'sees them' do
                    subject.scans.each do |scan|
                        expect(page).to have_content scan.name
                        expect(page).to have_content scan.site.to_s
                    end
                end

                scenario 'can edit' do
                    expect(page).to have_xpath "//a[@href='#{edit_profile_path( subject )}']"
                end

                scenario 'can copy' do
                    expect(page).to have_xpath "//a[@href='#{copy_profile_path( subject )}']"
                end

                scenario 'cannot delete' do
                    expect(page).to_not have_xpath "//a[@href='#{profile_path( subject )}' and @data-method='delete']"
                end
            end

            feature 'and the profile has no scans' do
                before do
                    subject.scans = []
                    subject.save

                    visit profile_path( subject )
                end

                scenario 'can edit' do
                    expect(page).to have_xpath "//a[@href='#{edit_profile_path( subject )}']"
                end

                scenario 'can copy' do
                    expect(page).to have_xpath "//a[@href='#{copy_profile_path( subject )}']"
                end

                scenario 'can delete' do
                    expect(page).to have_xpath "//a[@href='#{profile_path( subject )}' and @data-method='delete']"
                end
            end

            feature 'and the profile is default' do
                before do
                    subject.scans   = []
                    subject.default = true
                    subject.save

                    visit profile_path( subject )
                end

                scenario 'cannot delete' do
                    expect(page).to_not have_xpath "//a[@href='#{profile_path( subject )}' and @data-method='delete']"
                end
            end

            feature 'Scope' do
                feature 'Page limit' do
                    let(:option) { find('#scope_page_limit') }

                    feature 'when set' do
                        before do
                            subject.scope_page_limit = 99989
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'sees it' do
                            expect(option).to have_content subject.scope_page_limit.to_s
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.scope_page_limit = nil
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario "sees 'Infinite'" do
                            expect(option).to have_content 'Infinite'
                        end
                    end
                end

                feature 'Directory depth limit' do
                    let(:option) { find('#scope_directory_depth_limit') }

                    feature 'when set' do
                        before do
                            subject.scope_directory_depth_limit = 92989
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'sees it' do
                            expect(option).to have_content subject.scope_directory_depth_limit.to_s
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.scope_directory_depth_limit = nil
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario "sees 'Infinite'" do
                            expect(option).to have_content 'Infinite'
                        end
                    end
                end

                feature 'Path inclusion patterns' do
                    let(:option) { find('#scope_include_path_patterns') }

                    feature 'when set' do
                        before do
                            subject.scope_include_path_patterns = [
                                'stuff',
                                'more-stuff'
                            ]
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'sees them' do
                            subject.scope_include_path_patterns.each do |pattern|
                                expect(option).to have_content pattern
                            end
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.scope_include_path_patterns = []
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario "sees 'Include all resources'" do
                            expect(option).to have_content 'Include all resources'
                        end
                    end
                end

                feature 'Path exclusion patterns' do
                    let(:option) { find('#scope_exclude_path_patterns') }

                    feature 'when set' do
                        before do
                            subject.scope_exclude_path_patterns = [
                                'stuff',
                                'more-stuff'
                            ]
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'sees them' do
                            subject.scope_exclude_path_patterns.each do |pattern|
                                expect(option).to have_content pattern
                            end
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.scope_exclude_path_patterns = []
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario "sees 'Do not exclude any resources'" do
                            expect(option).to have_content 'Do not exclude any resources'
                        end
                    end
                end

                feature 'Advanced' do
                    let(:advanced) { find '#scope-advanced' }

                    feature 'Ignore binary content' do
                        let(:option) { advanced.find('#scope_exclude_binaries input') }

                        feature 'when set' do
                            before do
                                subject.scope_exclude_binaries = true
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'it is checked' do
                                expect(option).to be_checked
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.scope_exclude_binaries = false
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'it is not checked' do
                                expect(option).to_not be_checked
                            end
                        end
                    end

                    feature 'DOM depth limit' do
                        let(:option) { find('#scope_dom_depth_limit') }

                        feature 'when set' do
                            before do
                                subject.scope_dom_depth_limit = 192989
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'sees it' do
                                expect(option).to have_content subject.scope_dom_depth_limit.to_s
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.scope_dom_depth_limit = nil
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario "sees 'Infinite'" do
                                expect(option).to have_content 'Infinite'
                            end
                        end
                    end

                    feature 'Restrict paths' do
                        let(:option) { find('#scope_restrict_paths') }

                        feature 'when set' do
                            before do
                                subject.scope_restrict_paths = [
                                    '/stuff',
                                    '/more-stuff'
                                ]
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'sees them' do
                                subject.scope_restrict_paths.each do |path|
                                    expect(option).to have_content path
                                end
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.scope_restrict_paths = []
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario "sees 'Use paths discovered by the crawl'" do
                                expect(option).to have_content 'Use paths discovered by the crawl'
                            end
                        end
                    end

                    feature 'Extend paths' do
                        let(:option) { find('#scope_extend_paths') }

                        feature 'when set' do
                            before do
                                subject.scope_extend_paths = [
                                    '/stuff',
                                    '/more-stuff'
                                ]
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'sees them' do
                                subject.scope_extend_paths.each do |path|
                                    expect(option).to have_content path
                                end
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.scope_extend_paths = []
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario "sees 'Only use paths discovered by the crawl'" do
                                expect(option).to have_content 'Only use paths discovered by the crawl'
                            end
                        end
                    end

                    feature 'Content exclusion patterns' do
                        let(:option) { find('#scope_exclude_content_patterns') }

                        feature 'when set' do
                            before do
                                subject.scope_exclude_content_patterns = [
                                    'stuff',
                                    'more-stuff'
                                ]
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'sees them' do
                                subject.scope_exclude_content_patterns.each do |pattern|
                                    expect(option).to have_content pattern
                                end
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.scope_exclude_content_patterns = []
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario "sees 'Include all pages'" do
                                expect(option).to have_content 'Include all pages'
                            end
                        end
                    end
                end
            end

            feature 'Audit' do
                feature 'Forms' do
                    let(:option) { find('#audit_forms input') }

                    feature 'when set' do
                        before do
                            subject.audit_forms = true
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is checked' do
                            expect(option).to be_checked
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.audit_forms = false
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is not checked' do
                            expect(option).to_not be_checked
                        end
                    end
                end

                feature 'Links' do
                    let(:option) { find('#audit_links input') }

                    feature 'when set' do
                        before do
                            subject.audit_links = true
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is checked' do
                            expect(option).to be_checked
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.audit_links = false
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is not checked' do
                            expect(option).to_not be_checked
                        end
                    end
                end

                feature 'Cookies' do
                    let(:option) { find('#audit_cookies input') }

                    feature 'when set' do
                        before do
                            subject.audit_cookies = true
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is checked' do
                            expect(option).to be_checked
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.audit_cookies = false
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is not checked' do
                            expect(option).to_not be_checked
                        end
                    end
                end

                feature 'Headers' do
                    let(:option) { find('#audit_headers input') }

                    feature 'when set' do
                        before do
                            subject.audit_headers = true
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is checked' do
                            expect(option).to be_checked
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.audit_headers = false
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is not checked' do
                            expect(option).to_not be_checked
                        end
                    end
                end

                feature 'XML inputs' do
                    let(:option) { find('#audit_xmls input') }

                    feature 'when set' do
                        before do
                            subject.audit_xmls = true
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is checked' do
                            expect(option).to be_checked
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.audit_xmls = false
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is not checked' do
                            expect(option).to_not be_checked
                        end
                    end
                end

                feature 'JSON inputs' do
                    let(:option) { find('#audit_jsons input') }

                    feature 'when set' do
                        before do
                            subject.audit_jsons = true
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is checked' do
                            expect(option).to be_checked
                        end
                    end

                    feature 'when not set' do
                        before do
                            subject.audit_jsons = false
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'it is not checked' do
                            expect(option).to_not be_checked
                        end
                    end
                end

                feature 'Advanced' do
                    let(:advanced) { find '#audit-advanced' }

                    feature 'Audit with both http methods' do
                        let(:option) { advanced.find('#audit_with_both_http_methods input') }

                        feature 'when set' do
                            before do
                                subject.audit_with_both_http_methods = true
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'it is checked' do
                                expect(option).to be_checked
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.audit_with_both_http_methods = false
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'it is not checked' do
                                expect(option).to_not be_checked
                            end
                        end
                    end

                    feature 'Audit cookies extensively' do
                        let(:option) { advanced.find('#audit_cookies_extensively input') }

                        feature 'when set' do
                            before do
                                subject.audit_cookies_extensively = true
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'it is checked' do
                                expect(option).to be_checked
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.audit_cookies_extensively = false
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'it is not checked' do
                                expect(option).to_not be_checked
                            end
                        end
                    end

                    feature 'Audit parameter names' do
                        let(:option) { advanced.find('#audit_parameter_names input') }

                        feature 'when set' do
                            before do
                                subject.audit_parameter_names = true
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'it is checked' do
                                expect(option).to be_checked
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.audit_parameter_names = false
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'it is not checked' do
                                expect(option).to_not be_checked
                            end
                        end
                    end

                    feature 'Parameter inclusion patterns' do
                        let(:option) { find('#audit_include_vector_patterns') }

                        feature 'when set' do
                            before do
                                subject.audit_include_vector_patterns = [
                                    'stuff',
                                    'more-stuff'
                                ]
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'sees them' do
                                subject.audit_include_vector_patterns.each do |pattern|
                                    expect(option).to have_content pattern
                                end
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.audit_include_vector_patterns = []
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario "sees 'Include all parameters'" do
                                expect(option).to have_content 'Include all parameters'
                            end
                        end
                    end

                    feature 'Parameter exclusion patterns' do
                        let(:option) { find('#audit_exclude_vector_patterns') }

                        feature 'when set' do
                            before do
                                subject.audit_exclude_vector_patterns = [
                                    'stuff',
                                    'more-stuff'
                                ]
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario 'sees them' do
                                subject.audit_exclude_vector_patterns.each do |pattern|
                                    expect(option).to have_content pattern
                                end
                            end
                        end

                        feature 'when not set' do
                            before do
                                subject.audit_exclude_vector_patterns = []
                                subject.save

                                visit profile_path( subject )
                            end

                            scenario "sees 'Do not exclude any parameters'" do
                                expect(option).to have_content 'Do not exclude any parameters'
                            end
                        end
                    end
                end
            end

            feature 'Checks' do
                let(:checks) { find '#checks' }

                feature 'when no checks are selected' do
                    before do
                        subject.checks = []
                        subject.save

                        visit profile_path( subject )
                    end

                    scenario "sees 'No checks have been selected'" do
                        expect(checks).to have_content 'No checks have been selected'
                    end
                end

                feature 'Active' do
                    let(:active) { checks.find( '#checks-active' ) }

                    feature 'when active checks are selected' do
                        before do
                            subject.checks = %w(xss sql_injection captcha)
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'sees them' do
                            %w(xss sql_injection).each do |check|
                                expect(active).to have_css "##{check}"
                            end
                        end
                    end

                    feature 'when no active checks are selected' do
                        before do
                            subject.checks = %w(captcha)
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario "sees 'No active checks have been selected'" do
                            expect(active).to have_content 'No active checks have been selected'
                        end
                    end
                end

                feature 'Passive' do
                    let(:passive) { checks.find( '#checks-passive' ) }

                    feature 'when passive checks are selected' do
                        before do
                            subject.checks = %w(xss sql_injection captcha)
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario 'sees them' do
                            %w(captcha).each do |check|
                                expect(passive).to have_css "##{check}"
                            end
                        end
                    end

                    feature 'when no active checks are selected' do
                        before do
                            subject.checks = %w(xss sql_injection)
                            subject.save

                            visit profile_path( subject )
                        end

                        scenario "sees 'No passive checks have been selected'" do
                            expect(passive).to have_content 'No passive checks have been selected'
                        end
                    end
                end
            end

            feature 'Plugins' do
                let(:plugins) { find '#plugins' }

                feature 'when no plugins are selected' do
                    before do
                        subject.plugins = {}
                        subject.save

                        visit profile_path( subject )
                    end

                    scenario "sees 'No plugins have been selected'" do
                        expect(plugins).to have_content 'No plugins have been selected'
                    end
                end

                feature 'when plugins are selected' do
                    before do
                        subject.plugins = {
                            'content_types' => {
                                'exclude' => 'Stuff here'
                            }
                        }
                        subject.save

                        visit profile_path( subject )
                    end

                    scenario 'sees them' do
                        %w(content_types).each do |check|
                            expect(plugins).to have_css "##{check}"
                        end
                    end

                    scenario 'sees their options' do
                        expect(plugins.find('#profile_plugins_content_types_exclude').value).to eq 'Stuff here'
                    end
                end
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit profile_path( subject )
        end

        scenario 'gets redirected' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
