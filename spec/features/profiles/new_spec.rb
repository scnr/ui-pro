include Warden::Test::Helpers
Warden.test_mode!

feature 'Profile new page' do

    subject { FactoryGirl.create :profile, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:site) { FactoryGirl.create :site, user: user }

    after(:each) do
        Warden.test_reset!
    end

    def submit
        find( :xpath, "//input[@type='submit']" ).click
    end

    feature 'authenticated user' do
        before do
            user.profiles << subject

            login_as( user, scope: :user )
            visit new_profile_path
        end

        scenario 'has title' do
            expect(page).to have_title 'New'
            expect(page).to have_title 'Profiles'
        end

        scenario 'has breadcrumbs' do
            breadcrumbs = find('ul.bread')

            expect(breadcrumbs.find('li:nth-of-type(1) a').native['href']).to eq root_path

            expect(breadcrumbs.find('li:nth-of-type(2)')).to have_content 'Profiles'
            expect(breadcrumbs.find('li:nth-of-type(2) a').native['href']).to eq profiles_path

            expect(breadcrumbs.find('li:nth-of-type(3)')).to have_content 'New'
            expect(breadcrumbs.find('li:nth-of-type(3) a').native['href']).to eq new_profile_path
        end

        scenario 'sees profile form' do
            expect(find('.profile-form')).to be_truthy
        end

        scenario 'can submit form using sidebar button', js: true do
            fill_in 'profile_name', with: 'My name'
            fill_in 'profile_description', with: 'My description'

            find('#sidebar button').click
            sleep 1

            expect(Profile.last.name).to eq 'My name'
        end

        feature 'option' do
            before do
                fill_in 'profile_name', with: 'My name'
                fill_in 'profile_description', with: 'My description'
            end

            feature 'Name' do
                scenario 'can be set' do
                    fill_in 'profile_name', with: 'My name'
                    fill_in 'profile_description', with: 'My description'

                    submit

                    expect(Profile.last.name).to eq 'My name'
                end

                scenario 'is mandatory' do
                    fill_in 'profile_name', with: ''
                    fill_in 'profile_description', with: 'My description'

                    submit

                    expect(find('.profile_name.has-error').text).to include "can't be blank"
                end
            end

            feature 'Description' do
                scenario 'can be set' do
                    fill_in 'profile_name', with: 'My name'
                    fill_in 'profile_description', with: 'My description'

                    submit

                    expect(Profile.last.description).to eq 'My description'
                end

                scenario 'is mandatory' do
                    fill_in 'profile_name', with: 'My name'
                    fill_in 'profile_description', with: ''

                    submit

                    expect(find('.profile_description.has-error').text).to include "can't be blank"
                end
            end

            feature 'Scope' do
                scenario 'can set Page limit' do
                    fill_in 'Page limit', with: '10'
                    submit

                    expect(Profile.last.scope_page_limit).to eq 10
                end

                scenario 'can set Directory depth limit' do
                    fill_in 'Page limit', with: '10'
                    submit

                    expect(Profile.last.scope_page_limit).to eq 10
                end

                feature 'Path inclusion patterns' do
                    scenario 'can be set' do
                        fill_in 'Path inclusion patterns', with: "test\\w+\ninclude this (.*)"
                        submit

                        expect(Profile.last.scope_include_path_patterns).to eq [
                            /test\w+/.source,
                            /include this (.*)/.source
                        ]
                    end

                    feature 'when given invalid patterns' do
                        scenario 'shows error' do
                            rules = "(test\ntest4)"
                            exp = 'invalid pattern "(test" (end pattern with unmatched parenthesis: /(test/) and invalid pattern "test4)" (unmatched close parenthesis: /test4)/)'

                            fill_in 'Path inclusion patterns', with: rules
                            submit

                            expect(find('.profile_scope_include_path_patterns.has-error').text).to include exp
                        end
                    end
                end

                feature 'Path exclusion patterns' do
                    scenario 'can be set' do
                        fill_in 'Path exclusion patterns', with: "test\\w+\ninclude this (.*)"
                        submit

                        expect(Profile.last.scope_exclude_path_patterns).to eq [
                            /test\w+/.source,
                            /include this (.*)/.source
                        ]
                    end

                    feature 'when given invalid patterns' do
                        scenario 'shows error' do
                            rules = "(test\ntest4)"
                            exp = 'invalid pattern "(test" (end pattern with unmatched parenthesis: /(test/) and invalid pattern "test4)" (unmatched close parenthesis: /test4)/)'

                            fill_in 'Path exclusion patterns', with: rules
                            submit

                            expect(find('.profile_scope_exclude_path_patterns.has-error').text).to include exp
                        end
                    end
                end

                feature 'Advanced' do
                    scenario 'can set Ignore binary content' do
                        check 'Ignore binary content'
                        submit

                        expect(Profile.last.scope_exclude_binaries).to eq true
                    end

                    scenario 'can set DOM depth limit' do
                        fill_in 'DOM depth limit', with: '10'
                        submit

                        expect(Profile.last.scope_dom_depth_limit).to eq 10
                    end

                    feature 'Content exclusion patterns' do
                        scenario 'can be set ' do
                            fill_in 'Content exclusion patterns', with: "test\\w+\ninclude this (.*)"
                            submit

                            expect(Profile.last.scope_exclude_content_patterns).to eq [
                                /test\w+/.source,
                                /include this (.*)/.source
                            ]
                        end

                        feature 'when given invalid patterns' do
                            scenario 'shows error' do
                                rules = "(test\ntest4)"
                                exp = 'invalid pattern "(test" (end pattern with unmatched parenthesis: /(test/) and invalid pattern "test4)" (unmatched close parenthesis: /test4)/)'

                                fill_in 'Content exclusion patterns', with: rules
                                submit

                                expect(find('.profile_scope_exclude_content_patterns.has-error').text).to include exp
                            end
                        end
                    end

                    scenario 'can set Restrict paths' do
                        fill_in 'Restrict paths', with: "test\ntest2"
                        submit

                        expect(Profile.last.scope_restrict_paths).to eq [
                            'test', 'test2'
                        ]
                    end
                end
            end

            feature 'Audit' do
                scenario 'can set Audit forms' do
                    check 'Audit forms'
                    submit

                    expect(Profile.last.audit_forms).to eq true
                end

                scenario 'can set Audit UI forms' do
                    check 'Audit UI forms'
                    submit

                    expect(Profile.last.audit_ui_forms).to eq true
                end

                scenario 'can set Audit UI inputs' do
                    check 'Audit UI inputs'
                    submit

                    expect(Profile.last.audit_ui_inputs).to eq true
                end

                scenario 'can set Audit links' do
                    check 'Audit links'

                    expect(Profile.last.audit_links).to eq true
                end

                scenario 'can set Audit cookies' do
                    check 'Audit cookies'
                    submit

                    expect(Profile.last.audit_cookies).to eq true
                end

                scenario 'can set Audit headers' do
                    check 'Audit headers'
                    submit

                    expect(Profile.last.audit_headers).to eq true
                end

                scenario 'can set Audit JSON inputs' do
                    check 'Audit JSON inputs'
                    submit

                    expect(Profile.last.audit_jsons).to eq true
                end

                scenario 'can set Audit XML inputs' do
                    check 'Audit XML inputs'
                    submit

                    expect(Profile.last.audit_xmls).to eq true
                end

                feature 'Advanced' do
                    scenario 'can set Audit with both http methods' do
                        check 'Audit with both http methods'
                        submit

                        expect(Profile.last.audit_with_both_http_methods).to eq true
                    end

                    scenario 'can set Audit cookies extensively' do
                        check 'Audit cookies extensively'
                        submit

                        expect(Profile.last.audit_cookies_extensively).to eq true
                    end

                    scenario 'can set Audit with extra parameter' do
                        check 'Audit with extra parameter'
                        submit

                        expect(Profile.last.audit_with_extra_parameter).to eq true
                    end

                    scenario 'can set Audit parameter names' do
                        check 'Audit parameter names'
                        submit

                        expect(Profile.last.audit_parameter_names).to eq true
                    end

                    feature 'Parameter exclusion patterns' do
                        scenario 'can be set' do
                            fill_in 'Parameter exclusion patterns', with: "test\ntest2"
                            submit

                            expect(Profile.last.audit_exclude_vector_patterns).to eq [
                                'test', 'test2'
                            ]
                        end

                        feature 'when given invalid pattern' do
                            scenario 'shows error' do
                                fill_in 'Parameter exclusion patterns', with: '(articles'
                                submit

                                expect(find('.profile_audit_exclude_vector_patterns.has-error').text).to include 'invalid pattern'
                            end
                        end
                    end

                    feature 'Parameter inclusion patterns' do
                        scenario 'can be set' do
                            fill_in 'Parameter inclusion patterns', with: "test\ntest2"
                            submit

                            expect(Profile.last.audit_include_vector_patterns).to eq [
                                'test', 'test2'
                            ]
                        end

                        feature 'when given invalid pattern' do
                            scenario 'shows error' do
                                fill_in 'Parameter inclusion patterns', with: '(articles'
                                submit

                                expect(find('.profile_audit_include_vector_patterns.has-error').text).to include 'invalid pattern'
                            end
                        end
                    end
                end
            end

            feature 'Checks' do
                feature 'can be searched', js: true do
                    scenario 'by name' do
                        expect(page).to have_selector( '.profile-checks', count: 65 )

                        fill_in 'profile-checks-search', with: 'xss'

                        expect(page).to have_selector( '.profile-checks', count: 7 )
                    end

                    scenario 'by description' do
                        expect(page).to have_selector( '.profile-checks', count: 65 )

                        fill_in 'profile-checks-search', with: 'vulnerability'

                        expect(page).to have_selector( '.profile-checks', count: 7 )
                    end

                    scenario 'by platforms' do
                        expect(page).to have_selector( '.profile-checks', count: 65 )

                        fill_in 'profile-checks-search', with: 'php'

                        expect(page).to have_selector( '.profile-checks', count: 5 )
                    end

                    scenario 'by combination' do
                        expect(page).to have_selector( '.profile-checks', count: 65 )

                        fill_in 'profile-checks-search', with: 'injection assess php'

                        expect(page).to have_selector( '.profile-checks', count: 2 )
                    end
                end

                FrameworkHelper.checks.each do |shortname, info|
                    feature info[:name] do
                        let(:text) do
                            find("#profile-checks-#{shortname}-container").text
                        end
                        let(:description) do
                            find("##{shortname}-description").text.recode
                        end

                        scenario 'can be set' do
                            check "profile_checks_#{shortname}"
                            submit

                            expect(Profile.last.checks).to include shortname
                        end

                        scenario 'has description' do
                            expect(description).to include ActionView::Base.full_sanitizer.sanitize(
                                ApplicationHelper.md( info[:description] )
                            ).gsub( /\s+/m, ' ' ).strip.recode
                        end

                        scenario 'has version' do
                            expect(text).to include info[:version]
                        end

                        scenario 'has authors' do
                            info[:authors].each do |author|
                                expect(text).to include author
                            end
                        end

                        scenario 'has platforms', if: info[:platforms] do
                            info[:platforms].each do |platform|
                                fullname = FrameworkHelper.platform_fullname( platform )

                                expect(text).to include fullname
                            end
                        end
                    end
                end
            end

            feature 'Plugins' do
                feature 'Beep notify' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_beep_notify' )
                    end
                end

                feature 'Form dictionary attacker' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_form_dicattack' )
                    end
                end

                feature 'HTTP dictionary attacker' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_http_dicattack' )
                    end
                end

                feature 'Exec' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_exec' )
                    end
                end

                feature 'Content-types' do
                    before do
                        check 'profile_plugins_content_types'
                    end

                    scenario 'can be set without options' do
                        submit

                        expect(Profile.last.plugins['content_types']).to eq ({
                            'exclude' => 'text'
                        })
                    end

                    scenario 'can be set with options' do
                        fill_in 'profile_plugins_content_types_exclude', with: 'stuff'
                        submit

                        expect(Profile.last.plugins['content_types']).to eq ({
                            'exclude' => 'stuff'
                        })
                    end
                end

                feature 'Cookie collector' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_cookie_collector' )
                    end
                end

                feature 'E-mail notify' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_email_notify' )
                    end
                end

                feature 'Autologin' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_autologin' )
                    end
                end

                feature 'Login script' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_login_script' )
                    end
                end

                feature 'Headers collector' do
                    before do
                        check 'profile_plugins_headers_collector'
                    end

                    scenario 'can be set without options' do
                        submit

                        expect(Profile.last.plugins['headers_collector']).to eq ({
                            'include' => '',
                            'exclude' => ''
                        })
                    end

                    scenario 'can be set with options' do
                        fill_in 'profile_plugins_headers_collector_include', with: 'include_stuff'
                        fill_in 'profile_plugins_headers_collector_exclude', with: 'exclude_stuff'
                        submit

                        expect(Profile.last.plugins['headers_collector']).to eq ({
                            'include' => 'include_stuff',
                            'exclude' => 'exclude_stuff'
                        })
                    end
                end

                feature 'Proxy' do
                    before do
                        check 'profile_plugins_proxy'
                    end

                    scenario 'can be set without options' do
                        submit

                        expect(Profile.last.plugins['proxy']).to eq ({
                            'port'             => '8282',
                            'bind_address'     => '127.0.0.1',
                            'session_token'    => '',
                            'timeout'          => '20000'
                        })
                    end

                    scenario 'can be set with options' do
                        fill_in 'profile_plugins_proxy_port', with: '8080'
                        fill_in 'profile_plugins_proxy_bind_address', with: '127.0.0.2'
                        check 'profile_plugins_proxy_ignore_responses'
                        fill_in 'profile_plugins_proxy_session_token', with: 'secret'
                        fill_in 'profile_plugins_proxy_timeout', with: '10'
                        submit

                        expect(Profile.last.plugins['proxy']).to eq ({
                            'port'             => '8080',
                            'bind_address'     => '127.0.0.2',
                            'ignore_responses' => 'on',
                            'session_token'    => 'secret',
                            'timeout'          => '10'
                        })
                    end
                end

                feature 'Script' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_script' )
                    end
                end

                feature 'Uncommon headers' do
                    before do
                        check 'profile_plugins_uncommon_headers'
                    end

                    scenario 'can be set' do
                        submit

                        expect(Profile.last.plugins).to include 'uncommon_headers'
                    end
                end

                feature 'Vector collector' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_vector_collector' )
                    end
                end

                feature 'Vector feed' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_vector_feed' )
                    end
                end

                feature 'WAF Detector' do
                    scenario 'is not listed' do
                        expect(page).to_not have_selector( '#profile_plugins_waf_detector' )
                    end
                end
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit new_profile_path
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
