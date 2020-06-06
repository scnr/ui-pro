feature 'Revision coverage' do
    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site, user: user }
    let(:profile) { FactoryGirl.create :profile }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:revision) { FactoryGirl.create :revision, scan: scan }

    def refresh
        visit configuration_site_scan_revision_path( site, scan, revision )
    end

    before do
        revision

        user.sites << site

        login_as user, scope: :user

        refresh
    end

    after(:each) do
        Warden.test_reset!
    end

    let(:help_alert) { find '.alert-help' }
    let(:configuration) { find '#configuration' }
    let(:snapshot) { td.find ".#{attribute}-snapshot" }
    let(:current) { td.find ".#{attribute}-current" }

    feature 'Site settings' do
        let(:site_settings) { configuration.find '#configuration-site' }
        let(:heading) { site_settings.find 'h2' }
        let(:alert) { site_settings.find '#configuration-site-alert' }

        let(:td) { site_settings.find ".#{attribute}" }

        feature 'when they are the same as the snapshot' do
            scenario 'shows status in heading' do
                expect(heading).to have_content 'Up to date'
            end

            scenario 'shows status in alert' do
                expect(alert).to have_content 'same as current ones'
            end
        end

        feature 'when they differ from the snapshot' do
            before do
                site.profile.http_request_concurrency = 1
                site.profile.save

                refresh
            end

            scenario 'shows status in heading' do
                expect(heading).to have_content 'Out of date'
            end

            scenario 'shows status in alert' do
                expect(alert).to have_content 'different from current ones'
            end

            scenario 'shows help alert', js: true do
                expect(help_alert).to have_content 'Found the perfect configuration'

                within help_alert do
                    click_link 'site'
                    expect( URI(current_url).fragment ).to eq '!/configuration-site'
                end
            end
        end

        feature 'Platforms' do
            let(:platforms) { site_settings.find '#configuration-site-platforms' }

            feature 'Selected' do
                before do
                    revision.site_profile.platforms = [:php, :mysql]
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'platforms' }

                feature 'when empty' do
                    before do
                        revision.site_profile.platforms = []
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.platforms.each do |platform|
                            expect(snapshot).to have_content FrameworkHelper.platform_fullname( platform )
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.platforms = revision.site_profile.platforms
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.platforms = [:rails, :nginx]
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.platforms.each do |platform|
                            expect(current).to have_content FrameworkHelper.platform_fullname( platform )
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.platforms).to_not eq revision.site_profile.platforms

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.platforms).to eq revision.site_profile.platforms
                    end
                end
            end

            feature 'Fingerprinting' do
                before do
                    revision.site_profile.no_fingerprinting = true
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'no_fingerprinting' }

                feature 'when true' do
                    before do
                        revision.site_profile.no_fingerprinting = true
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'Disabled'" do
                        expect(snapshot).to have_content 'Disabled'
                    end
                end

                feature 'when false' do
                    before do
                        revision.site_profile.no_fingerprinting = false
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'Enabled'" do
                        expect(snapshot).to have_content 'Enabled'
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.no_fingerprinting =
                            revision.site_profile.no_fingerprinting
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.no_fingerprinting = false
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'shows it' do
                        expect(current).to have_content 'Enabled'
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.no_fingerprinting).to_not eq revision.site_profile.no_fingerprinting

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.no_fingerprinting).to eq revision.site_profile.no_fingerprinting
                    end
                end
            end
        end

        feature 'Scope' do
            feature 'Parameter redundancy limit' do
                before do
                    revision.site_profile.scope_auto_redundant_paths = 20
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'scope_auto_redundant_paths' }

                scenario 'shows value' do
                    expect(snapshot).to have_content '20'
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.scope_auto_redundant_paths =
                            revision.site_profile.scope_auto_redundant_paths
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.scope_auto_redundant_paths = 10
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'shows value' do
                        expect(current).to have_content '10'
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.scope_auto_redundant_paths).to_not eq revision.site_profile.scope_auto_redundant_paths

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.scope_auto_redundant_paths).to eq revision.site_profile.scope_auto_redundant_paths
                    end
                end
            end

            feature 'Template patterns' do
                before do
                    revision.site_profile.scope_template_path_patterns = [
                        /redundant 1/,
                        /redundant 2/
                    ]
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'scope_template_path_patterns' }

                feature 'when empty' do
                    before do
                        revision.site_profile.scope_template_path_patterns = []
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.scope_template_path_patterns.each do |pattern|
                            expect(snapshot).to have_content pattern.source
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.scope_template_path_patterns =
                            revision.site_profile.scope_template_path_patterns
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.scope_template_path_patterns = [
                            /redundant 2/,
                            /redundant 3/
                        ]
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.scope_template_path_patterns.each do |pattern|
                            expect(current).to have_content pattern.source
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.scope_template_path_patterns).to_not eq revision.site_profile.scope_template_path_patterns

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.scope_template_path_patterns).to eq revision.site_profile.scope_template_path_patterns
                    end
                end
            end

            feature 'Exclusion patterns' do
                before do
                    revision.site_profile.scope_exclude_path_patterns = [
                        /pattern 1/,
                        /pattern 2/
                    ]
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'scope_exclude_path_patterns' }

                feature 'when empty' do
                    before do
                        revision.site_profile.scope_exclude_path_patterns = []
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.scope_exclude_path_patterns.each do |pattern|
                            expect(snapshot).to have_content pattern.source
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.scope_exclude_path_patterns =
                            revision.site_profile.scope_exclude_path_patterns
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.scope_exclude_path_patterns = [
                            /pattern 2/,
                            /pattern 3/
                        ]
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.scope_exclude_path_patterns.each do |pattern|
                            expect(current).to have_content pattern.source
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.scope_exclude_path_patterns).to_not eq revision.site_profile.scope_exclude_path_patterns

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.scope_exclude_path_patterns).to eq revision.site_profile.scope_exclude_path_patterns
                    end
                end
            end

            feature 'Content exclusion patterns' do
                before do
                    revision.site_profile.scope_exclude_content_patterns = [
                        /pattern 1/,
                        /pattern 2/
                    ]
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'scope_exclude_content_patterns' }

                feature 'when empty' do
                    before do
                        revision.site_profile.scope_exclude_content_patterns = []
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.scope_exclude_content_patterns.each do |pattern|
                            expect(snapshot).to have_content pattern.source
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.scope_exclude_content_patterns =
                            revision.site_profile.scope_exclude_content_patterns
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.scope_exclude_content_patterns = [
                            /pattern 2/,
                            /pattern 3/
                        ]
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.scope_exclude_content_patterns.each do |pattern|
                            expect(current).to have_content pattern.source
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.scope_exclude_content_patterns).to_not eq revision.site_profile.scope_exclude_content_patterns

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.scope_exclude_content_patterns).to eq revision.site_profile.scope_exclude_content_patterns
                    end
                end
            end

            feature 'Exclude file extensions' do
                before do
                    revision.site_profile.scope_exclude_file_extensions = [
                        'css',
                        'jpg'
                    ]
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'scope_exclude_file_extensions' }

                feature 'when empty' do
                    before do
                        revision.site_profile.scope_exclude_file_extensions = []
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.scope_exclude_file_extensions.each do |ext|
                            expect(snapshot).to have_content ext
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.scope_exclude_file_extensions =
                            revision.site_profile.scope_exclude_file_extensions
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.scope_exclude_file_extensions = [
                            'css',
                            'jpeg'
                        ]
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.scope_exclude_file_extensions.each do |ext|
                            expect(current).to have_content ext
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.scope_exclude_file_extensions).to_not eq revision.site_profile.scope_exclude_file_extensions

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.scope_exclude_file_extensions).to eq revision.site_profile.scope_exclude_file_extensions
                    end
                end
            end

            feature 'Extend paths' do
                before do
                    revision.site_profile.scope_extend_paths = [
                        '/path/1',
                        '/path/2'
                    ]
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'scope_extend_paths' }

                feature 'when empty' do
                    before do
                        revision.site_profile.scope_extend_paths = []
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty', js: true do
                    scenario 'it lists them in modal' do
                        within snapshot do
                            click_button 'Show'
                        end

                        modal = snapshot.find( '.modal' )

                        expect(modal).to be_visible

                        revision.site_profile.scope_extend_paths.each do |path|
                            expect(modal).to have_content path
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.scope_extend_paths =
                            revision.site_profile.scope_extend_paths
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.scope_extend_paths = [
                            '/path/2',
                            '/path/3'
                        ]
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    feature 'when not empty', js: true do
                        scenario 'it lists them in modal' do
                            within current do
                                click_button 'Show'
                            end

                            modal = current.find( '.modal' )

                            expect(modal).to be_visible

                            site.profile.scope_extend_paths.each do |path|
                                expect(modal).to have_content path
                            end
                        end
                    end
                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.scope_extend_paths).to_not eq revision.site_profile.scope_extend_paths

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.scope_extend_paths).to eq revision.site_profile.scope_extend_paths
                    end
                end
            end
        end

        feature 'Inputs' do
            feature 'Custom inputs' do
                before do
                    revision.site_profile.audit_link_templates = [
                        /input1\/(?<input1>\w+)\/input2\/(?<input2>\w+)/,
                        /input3\/(?<input3>\w+)\/input4\/(?<input4>\w+)/
                    ]
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'audit_link_templates' }

                feature 'when empty' do
                    before do
                        revision.site_profile.audit_link_templates = []
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.audit_link_templates.each do |pattern|
                            expect(snapshot).to have_content pattern.source
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.audit_link_templates =
                            revision.site_profile.audit_link_templates
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.audit_link_templates = [
                            /input5\/(?<input5>\w+)\/input6\/(?<input6>\w+)/,
                            /input7\/(?<input7>\w+)\/input8\/(?<input8>\w+)/
                        ]
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.audit_link_templates.each do |pattern|
                            expect(current).to have_content pattern.source
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.audit_link_templates).to_not eq revision.site_profile.audit_link_templates

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.audit_link_templates).to eq revision.site_profile.audit_link_templates
                    end
                end
            end

            feature 'URL rewrites' do
                before do
                    revision.site_profile.scope_url_rewrites = {
                        '/articles\/[\w-]+\/(\d+)/' => 'articles.php?id=\1'
                    }
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'scope_url_rewrites' }

                feature 'when empty' do
                    before do
                        revision.site_profile.scope_url_rewrites = {}
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.scope_url_rewrites.each do |pattern, rewrite|
                            expect(snapshot).to have_content "#{pattern} => #{rewrite}"
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.scope_url_rewrites =
                            revision.site_profile.scope_url_rewrites
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.scope_url_rewrites = {
                            '/posts\/[\w-]+\/(\d+)/' => 'posts.php?id=\1'
                        }
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.scope_url_rewrites.each do |pattern, rewrite|
                            expect(current).to have_content "#{pattern} => #{rewrite}"
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.scope_url_rewrites).to_not eq revision.site_profile.scope_url_rewrites

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.scope_url_rewrites).to eq revision.site_profile.scope_url_rewrites
                    end
                end
            end

            feature 'Fill-in values' do
                before do
                    revision.site_profile.input_values = {
                        'name'     => 'John',
                        'password' => 'secret'
                    }
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'input_values' }

                feature 'when empty' do
                    before do
                        revision.site_profile.input_values = {}
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.input_values.each do |name, value|
                            expect(snapshot).to have_content "#{name} = #{value}"
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.input_values =
                            revision.site_profile.input_values
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.input_values = {
                            'name'     => 'George',
                            'password' => 'secret1'
                        }
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.input_values.each do |name, value|
                            expect(current).to have_content "#{name} = #{value}"
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.input_values).to_not eq revision.site_profile.input_values

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.input_values).to eq revision.site_profile.input_values
                    end
                end
            end
        end

        feature 'HTTP' do
            feature 'Username' do
                before do
                    revision.site_profile.http_authentication_username = 'root'
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'http_authentication_username' }

                scenario 'shows value' do
                    expect(snapshot).to have_content 'root'
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.http_authentication_username =
                            revision.site_profile.http_authentication_username
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.http_authentication_username = 'john'
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'shows value' do
                        expect(current).to have_content 'john'
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.http_authentication_username).to_not eq revision.site_profile.http_authentication_username

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.http_authentication_username).to eq revision.site_profile.http_authentication_username
                    end
                end
            end

            feature 'Password' do
                before do
                    revision.site_profile.http_authentication_password = 'secret'
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'http_authentication_password' }

                scenario 'shows value' do
                    expect(snapshot).to have_content 'secret'
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.http_authentication_password =
                            revision.site_profile.http_authentication_password
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.http_authentication_password = 'secret!'
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'shows value' do
                        expect(current).to have_content 'secret!'
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.http_authentication_password).to_not eq revision.site_profile.http_authentication_password

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.http_authentication_password).to eq revision.site_profile.http_authentication_password
                    end
                end
            end

            feature 'Cookies' do
                before do
                    revision.site_profile.http_cookies = {
                        'name'    => 'John',
                        'session' => 'secret'
                    }
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'http_cookies' }

                feature 'when empty' do
                    before do
                        revision.site_profile.http_cookies = {}
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.http_cookies.each do |name, value|
                            expect(snapshot).to have_content "#{name} = #{value}"
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.http_cookies =
                            revision.site_profile.http_cookies
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.http_cookies = {
                            'name'    => 'John2',
                            'session' => 'secret2'
                        }
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.http_cookies.each do |name, value|
                            expect(current).to have_content "#{name} = #{value}"
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.http_cookies).to_not eq revision.site_profile.http_cookies

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.http_cookies).to eq revision.site_profile.http_cookies
                    end
                end
            end

            feature 'Headers' do
                before do
                    revision.site_profile.http_request_headers = {
                        'name'    => 'John',
                        'session' => 'secret'
                    }
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'http_request_headers' }

                feature 'when empty' do
                    before do
                        revision.site_profile.http_request_headers = {}
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.http_request_headers.each do |name, value|
                            expect(snapshot).to have_content "#{name} = #{value}"
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.http_request_headers =
                            revision.site_profile.http_request_headers
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.http_request_headers = {
                            'name'    => 'John2',
                            'session' => 'secret2'
                        }
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.http_request_headers.each do |name, value|
                            expect(current).to have_content "#{name} = #{value}"
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.http_request_headers).to_not eq revision.site_profile.http_request_headers

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.http_request_headers).to eq revision.site_profile.http_request_headers
                    end
                end
            end

            feature 'Request concurrency' do
                before do
                    revision.site_profile.http_request_concurrency = '20'
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'http_request_concurrency' }

                scenario 'shows value' do
                    expect(snapshot).to have_content '20'
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.http_request_concurrency =
                            revision.site_profile.http_request_concurrency
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.http_request_concurrency = '10'
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'shows value' do
                        expect(current).to have_content '10'
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.http_request_concurrency).to_not eq revision.site_profile.http_request_concurrency

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.http_request_concurrency).to eq revision.site_profile.http_request_concurrency
                    end
                end
            end
        end

        feature 'Browser' do
            feature 'Wait for elements to appear' do
                before do
                    revision.site_profile.browser_cluster_wait_for_elements = {
                        '^((?!#).)*$' => '#myElement'
                    }
                    revision.site_profile.save

                    refresh
                end

                let(:attribute) { 'browser_cluster_wait_for_elements' }

                feature 'when empty' do
                    before do
                        revision.site_profile.browser_cluster_wait_for_elements = {}
                        revision.site_profile.save

                        refresh
                    end

                    scenario "shows 'None'" do
                        expect(snapshot).to have_content 'None'
                    end
                end

                feature 'when not empty' do
                    scenario 'it lists them' do
                        revision.site_profile.browser_cluster_wait_for_elements.each do |pattern, css|
                            expect(snapshot).to have_content "#{pattern} => #{css}"
                        end
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        site.profile.browser_cluster_wait_for_elements =
                            revision.site_profile.browser_cluster_wait_for_elements
                        site.profile.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        site.profile.browser_cluster_wait_for_elements = {
                            '^((?!#).)*$' => '#myElement2'
                        }
                        site.profile.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        site.profile.browser_cluster_wait_for_elements.each do |pattern, css|
                            expect(current).to have_content "#{pattern} => #{css}"
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(site.profile.browser_cluster_wait_for_elements).to_not eq revision.site_profile.browser_cluster_wait_for_elements

                        within heading do
                            click_link 'Revert'
                        end

                        expect(site.profile.reload.browser_cluster_wait_for_elements).to eq revision.site_profile.browser_cluster_wait_for_elements
                    end
                end
            end
        end
    end

    feature 'User role' do
        let(:site_role) { configuration.find '#configuration-site_role' }
        let(:heading) { site_role.find 'h2' }
        let(:td) { site_role.find ".#{attribute}" }

        feature 'when the role is a guest' do
            before do
                scan.site_role.login_type = 'none'
                scan.site_role.save

                refresh
            end

            scenario 'does have Revert button' do
                expect(heading).to_not have_link 'Revert'
            end

            scenario 'does not show session settings' do
                expect(site_role).to_not have_css '#configuration-site_role-session'
            end

            scenario 'does not show login settings' do
                expect(site_role).to_not have_css '#configuration-site_role-login'
            end
        end

        feature 'when the role is not a guest' do
            feature 'when they are the same as the Revision options' do
                scenario 'shows status in heading' do
                    expect(heading).to have_content 'Up to date'
                end
            end

            feature 'when they differ from Revision options' do
                before do
                    scan.site_role.session_check_url = "#{scan.url}/account"
                    scan.site_role.save

                    refresh
                end

                scenario 'shows status in heading' do
                    expect(heading).to have_content 'Out of date'
                end

                scenario 'Revert button sets Site options to Revision options' do
                    expect(scan.site_role.session_check_url).to_not eq revision.site_role.session_check_url

                    within heading do
                        click_link 'Revert'
                    end

                    expect(scan.site_role.reload.session_check_url).to eq revision.site_role.session_check_url
                end

                scenario 'shows help alert', js: true do
                    expect(help_alert).to have_content 'Found the perfect configuration'

                    within help_alert do
                        click_link 'user role'
                        expect( URI(current_url).fragment ).to eq '!/configuration-site_role'
                    end
                end
            end

            feature 'Check URL' do
                before do
                    revision.site_role.session_check_url = 'http://test/'
                    revision.site_role.save

                    refresh
                end

                let(:attribute) { 'session_check_url' }

                scenario 'shows value' do
                    expect(snapshot).to have_content 'http://test/'
                end

                feature 'when identical to the snapshot' do
                    before do
                        scan.site_role.session_check_url =
                            revision.site_role.session_check_url
                        scan.site_role.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        scan.site_role.session_check_url = 'http://test/2'
                        scan.site_role.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'shows value' do
                        expect(current).to have_content 'http://test/2'
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(scan.site_role.session_check_url).to_not eq revision.site_role.session_check_url

                        within heading do
                            click_link 'Revert'
                        end

                        expect(scan.site_role.reload.session_check_url).to eq revision.site_role.session_check_url
                    end
                end
            end

            feature 'Check pattern' do
                before do
                    revision.site_role.session_check_pattern = '/logout/'
                    revision.site_role.save

                    refresh
                end

                let(:attribute) { 'session_check_pattern' }

                scenario 'shows value' do
                    expect(snapshot).to have_content '/logout/'
                end

                feature 'when identical to the snapshot' do
                    before do
                        scan.site_role.session_check_pattern =
                            revision.site_role.session_check_pattern
                        scan.site_role.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        scan.site_role.session_check_pattern = '/logout2/'
                        scan.site_role.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'shows value' do
                        expect(current).to have_content '/logout2/'
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(scan.site_role.session_check_pattern).to_not eq revision.site_role.session_check_pattern

                        within heading do
                            click_link 'Revert'
                        end

                        expect(scan.site_role.reload.session_check_pattern).to eq revision.site_role.session_check_pattern
                    end
                end
            end

            feature 'Logout exclusion patterns' do
                before do
                    revision.site_role.scope_exclude_path_patterns = [
                        /pattern 1/,
                        /pattern 2/
                    ]
                    revision.site_role.save

                    refresh
                end

                let(:attribute) { 'scope_exclude_path_patterns' }

                scenario 'it lists them' do
                    revision.site_role.scope_exclude_path_patterns.each do |pattern|
                        expect(snapshot).to have_content pattern.source
                    end
                end

                feature 'when identical to the snapshot' do
                    before do
                        scan.site_role.scope_exclude_path_patterns =
                            revision.site_role.scope_exclude_path_patterns
                        scan.site_role.save

                        refresh
                    end

                    scenario 'does not show current ones' do
                        expect { current }.to raise_error Capybara::ElementNotFound
                    end
                end

                feature 'when different from the snapshot' do
                    before do
                        scan.site_role.scope_exclude_path_patterns = [
                            /pattern 2/,
                            /pattern 3/
                        ]
                        scan.site_role.save

                        refresh
                    end

                    scenario 'highlights the snapshot value' do
                        expect(snapshot[:class]).to have_content 'bg-warning'
                    end

                    scenario 'highlights the current value' do
                        expect(current[:class]).to have_content 'bg-info'
                    end

                    scenario 'it lists current ones' do
                        scan.site_role.scope_exclude_path_patterns.each do |pattern|
                            expect(current).to have_content pattern.source
                        end
                    end

                    scenario 'toggle button hides current ones', js: true do
                        expect(current).to be_visible

                        within td do
                            click_button 'Toggle visibility of current value'
                        end

                        sleep 1

                        expect(current).to_not be_visible
                    end

                    scenario 'Revert button sets Site options to Revision options' do
                        expect(scan.site_role.scope_exclude_path_patterns).to_not eq revision.site_role.scope_exclude_path_patterns

                        within heading do
                            click_link 'Revert'
                        end

                        expect(scan.site_role.reload.scope_exclude_path_patterns).to eq revision.site_role.scope_exclude_path_patterns
                    end
                end
            end

            feature 'Login' do
                feature 'when form based' do
                    before do
                        revision.site_role.login_type = 'form'
                        revision.site_role.save
                    end

                    feature 'Form URL' do
                        before do
                            revision.site_role.login_form_url = 'http://test/'
                            revision.site_role.save

                            refresh
                        end

                        let(:attribute) { 'login_form_url' }

                        scenario 'shows value' do
                            expect(snapshot).to have_content 'http://test/'
                        end

                        feature 'when identical to the snapshot' do
                            before do
                                scan.site_role.login_form_url =
                                    revision.site_role.login_form_url
                                scan.site_role.save

                                refresh
                            end

                            scenario 'does not show current ones' do
                                expect { current }.to raise_error Capybara::ElementNotFound
                            end
                        end

                        feature 'when different from the snapshot' do
                            before do
                                revision.site_role.login_type = 'form'
                                scan.site_role.login_form_url = 'http://test/2'
                                scan.site_role.save

                                refresh
                            end

                            scenario 'highlights the snapshot value' do
                                expect(snapshot[:class]).to have_content 'bg-warning'
                            end

                            scenario 'highlights the current value' do
                                expect(current[:class]).to have_content 'bg-info'
                            end

                            scenario 'shows value' do
                                expect(current).to have_content 'http://test/2'
                            end

                            scenario 'toggle button hides current ones', js: true do
                                expect(current).to be_visible

                                within td do
                                    click_button 'Toggle visibility of current value'
                                end

                                sleep 1

                                expect(current).to_not be_visible
                            end

                            scenario 'Revert button sets Site options to Revision options' do
                                expect(scan.site_role.login_form_url).to_not eq revision.site_role.login_form_url

                                within heading do
                                    click_link 'Revert'
                                end

                                expect(scan.site_role.reload.login_form_url).to eq revision.site_role.login_form_url
                            end
                        end
                    end

                    feature 'Parameters' do
                        before do
                            revision.site_role.login_form_parameters = {
                                'name'    => 'John',
                                'session' => 'secret'
                            }
                            revision.site_role.save

                            refresh
                        end

                        let(:attribute) { 'login_form_parameters' }

                        scenario 'it lists them' do
                            revision.site_role.login_form_parameters.each do |name, value|
                                expect(snapshot).to have_content "#{name} = #{value}"
                            end
                        end

                        feature 'when identical to the snapshot' do
                            before do
                                scan.site_role.login_form_parameters =
                                    revision.site_role.login_form_parameters
                                scan.site_role.save

                                refresh
                            end

                            scenario 'does not show current ones' do
                                expect { current }.to raise_error Capybara::ElementNotFound
                            end
                        end

                        feature 'when different from the snapshot' do
                            before do
                                scan.site_role.login_form_parameters = {
                                    'name'    => 'John2',
                                    'session' => 'secret2'
                                }
                                scan.site_role.save

                                refresh
                            end

                            scenario 'highlights the snapshot value' do
                                expect(snapshot[:class]).to have_content 'bg-warning'
                            end

                            scenario 'highlights the current value' do
                                expect(current[:class]).to have_content 'bg-info'
                            end

                            scenario 'it lists current ones' do
                                scan.site_role.login_form_parameters.each do |name, value|
                                    expect(current).to have_content "#{name} = #{value}"
                                end
                            end

                            scenario 'toggle button hides current ones', js: true do
                                expect(current).to be_visible

                                within td do
                                    click_button 'Toggle visibility of current value'
                                end

                                sleep 1

                                expect(current).to_not be_visible
                            end

                            scenario 'Revert button sets Site options to Revision options' do
                                expect(scan.site_role.login_form_parameters).to_not eq revision.site_role.login_form_parameters

                                within heading do
                                    click_link 'Revert'
                                end

                                expect(scan.site_role.reload.login_form_parameters).to eq revision.site_role.login_form_parameters
                            end
                        end
                    end

                    feature 'and the current one is source based' do
                        before do
                            scan.site_role.login_type        = 'script'
                            scan.site_role.login_script_code = '#test2'
                            scan.site_role.save

                            refresh
                        end

                        let(:attribute) { 'login_type' }

                        scenario 'shows the current one' do
                            expect(current).to have_content '#test2'
                        end

                        scenario 'toggle button hides current ones', js: true do
                            expect(current).to be_visible

                            within td do
                                click_button 'Toggle visibility of current value'
                            end

                            sleep 1

                            expect(current).to_not be_visible
                        end

                        scenario 'Revert button sets Site options to Revision options' do
                            expect(scan.site_role.login_type).to_not eq revision.site_role.login_type
                            expect(scan.site_role.login_script_code).to_not eq revision.site_role.login_script_code

                            within heading do
                                click_link 'Revert'
                            end

                            expect(scan.site_role.reload.login_type).to eq revision.site_role.login_type
                            expect(scan.site_role.reload.login_script_code).to eq revision.site_role.login_script_code
                        end
                    end
                end

                feature 'when script based' do
                    before do
                        revision.site_role.login_type        = 'script'
                        revision.site_role.login_script_code = '#test'
                        revision.site_role.save

                        refresh
                    end

                    let(:attribute) { 'login_script_code' }

                    scenario 'shows it' do
                        expect(snapshot).to have_content '#test'
                    end

                    feature 'when identical to the snapshot' do
                        before do
                            scan.site_role.login_type        = 'script'
                            scan.site_role.login_script_code =
                                revision.site_role.login_script_code
                            scan.site_role.save

                            refresh
                        end

                        scenario 'does not show current ones' do
                            expect { current }.to raise_error Capybara::ElementNotFound
                        end
                    end

                    feature 'when different from the snapshot' do
                        before do
                            scan.site_role.login_type        = 'script'
                            scan.site_role.login_script_code = '#test2'
                            scan.site_role.save

                            refresh
                        end

                        scenario 'highlights the snapshot value' do
                            expect(snapshot[:class]).to have_content 'bg-warning'
                        end

                        scenario 'highlights the current value' do
                            expect(current[:class]).to have_content 'bg-info'
                        end

                        scenario 'shows the current one' do
                            expect(current).to have_content '#test2'
                        end

                        scenario 'toggle button hides current ones', js: true do
                            expect(current).to be_visible

                            within td do
                                click_button 'Toggle visibility of current value'
                            end

                            sleep 1

                            expect(current).to_not be_visible
                        end

                        scenario 'Revert button sets Site options to Revision options' do
                            expect(scan.site_role.login_script_code).to_not eq revision.site_role.login_script_code

                            within heading do
                                click_link 'Revert'
                            end

                            expect(scan.site_role.reload.login_script_code).to eq revision.site_role.login_script_code
                        end
                    end

                    feature 'and the current one is form based' do
                        before do
                            scan.site_role.login_type = 'form'
                            scan.site_role.save
                        end

                        feature 'Form URL' do
                            before do
                                scan.site_role.login_form_url = 'http://test/'
                                scan.site_role.save

                                refresh
                            end

                            let(:attribute) { 'login_form_url' }

                            scenario 'shows value' do
                                expect(snapshot).to have_content 'http://test/'
                            end

                            scenario 'Revert button sets Site options to Revision options' do
                                expect(scan.site_role.login_type).to_not eq revision.site_role.login_type
                                expect(scan.site_role.login_form_url).to_not eq revision.site_role.login_form_url

                                within heading do
                                    click_link 'Revert'
                                end

                                expect(scan.site_role.reload.login_type).to eq revision.site_role.login_type
                                expect(scan.site_role.reload.login_form_url).to eq revision.site_role.login_form_url
                            end
                        end

                        feature 'Parameters' do
                            before do
                                scan.site_role.login_form_parameters = {
                                    'name'    => 'John',
                                    'session' => 'secret'
                                }
                                scan.site_role.save

                                refresh
                            end

                            let(:attribute) { 'login_form_parameters' }

                            scenario 'it lists them' do
                                scan.site_role.login_form_parameters.each do |name, value|
                                    expect(snapshot).to have_content "#{name} = #{value}"
                                end
                            end

                            scenario 'Revert button sets Site options to Revision options' do
                                expect(scan.site_role.login_type).to_not eq revision.site_role.login_type
                                expect(scan.site_role.login_form_parameters).to_not eq revision.site_role.login_form_parameters

                                within heading do
                                    click_link 'Revert'
                                end

                                expect(scan.site_role.reload.login_type).to eq revision.site_role.login_type
                                expect(scan.site_role.reload.login_form_parameters).to eq revision.site_role.login_form_parameters
                            end
                        end
                    end
                end
            end
        end
    end

end
