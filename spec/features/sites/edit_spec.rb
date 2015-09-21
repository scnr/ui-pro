feature 'Site profile form' do
    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:profile) { FactoryGirl.create :profile }

    let(:site) { FactoryGirl.create :site, profile: nil }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: FactoryGirl.create( :profile ) }
    let(:revision) { FactoryGirl.create :revision, scan: scan }

    let(:https_site) { FactoryGirl.create :site, protocol: 'https' }
    let(:https_scan) { FactoryGirl.create :scan, site: https_site, profile: FactoryGirl.create( :profile ) }
    let(:https_revision) { FactoryGirl.create :revision, scan: https_scan }

    let(:settings) { Settings }

    before do
        revision
        user.sites << site

        login_as user, scope: :user
        visit edit_site_path( site )
    end

    after(:each) do
        Warden.test_reset!
    end

    def submit
        find( :xpath, "//input[@type='submit']" ).click
    end

    def submit_via_sidebar
        find('#sidebar button').click
    end

    let(:profile) { site.reload.profile }

    let(:site_sidebar_selected_button) { "a[@href='#{current_path}']" }
    it_behaves_like 'Site sidebar'

    scenario 'sees profile form' do
        expect(find('.profile-form')).to be_truthy
    end

    scenario 'can submit form using sidebar button', js: true do
        fill_in 'Parameter redundancy limit', with: 10

        submit_via_sidebar
        sleep 1

        expect(profile.scope_auto_redundant_paths).to eq 10
    end

    feature 'when the form is submitted' do
        scenario 'redirects to settings', js: true do
            submit_via_sidebar
            sleep 1

            expect(current_url).to end_with edit_site_path( site )
        end
    end

    feature 'option' do

        feature 'Scans' do
            feature 'Maximum parallel scans' do
                before do
                    settings.max_parallel_scans = 5
                    settings.save
                end

                scenario 'can be set' do
                    fill_in 'Maximum parallel scans', with: 1
                    submit

                    expect(site.reload.max_parallel_scans).to eq 1
                end

                feature 'when its value is greater than the global setting' do
                    scenario 'shows error' do
                        fill_in 'Maximum parallel scans', with: 10
                        submit

                        expect(find('div.site_max_parallel_scans.has-error')).to have_content "cannot be greater than the global setting of #{settings.max_parallel_scans}"
                    end
                end

                feature 'when its value is 0' do
                    scenario 'shows error' do
                        fill_in 'Maximum parallel scans', with: 0
                        submit

                        expect(find('div.site_max_parallel_scans.has-error')).to have_content 'must be greater than 0'
                    end
                end

                feature 'when its value is less than 0' do
                    scenario 'shows error' do
                        fill_in 'Maximum parallel scans', with: -1
                        submit

                        expect(find('div.site_max_parallel_scans.has-error')).to have_content 'must be greater than 0'
                    end
                end
            end
        end

        feature 'Scope' do
            feature 'when the site uses HTTPS' do
                before do
                    https_revision
                    user.sites << https_site
                    visit edit_site_path( https_site )
                end

                scenario 'can set Only follow HTTPS URLs' do
                    check 'Only follow HTTPS URLs'
                    submit

                    expect(https_site.reload.profile.reload.scope_https_only).to eq true
                end
            end

            feature 'when the site uses HTTP' do
                scenario 'Only follow HTTPS URLs option is not visible' do
                    expect(page.text).to_not include 'Only follow HTTPS URLs'
                end
            end

            feature 'URL rewrite rules' do
                scenario 'can be set' do
                    rules = "/articles\/[\w-]+\/(\d+)/:articles.php?id=\\1\n"
                    rules << "/photos\/[\w-]+\/(\d+)/:photos.php?id=\\1"

                    fill_in 'URL rewrite rules', with: rules
                    submit

                    expect(profile.scope_url_rewrites).to eq ({
                        '/articles/[w-]+/(d+)/' => 'articles.php?id=\1',
                        '/photos/[w-]+/(d+)/'   => 'photos.php?id=\1'
                    })
                end

                feature 'when missing captures' do
                    scenario 'shows error' do
                        rules = "/articles\/[\w-]+\/\d+/:articles.php?id=\1\n"

                        fill_in 'URL rewrite rules', with: rules
                        submit

                        expect(find('.site_profile_scope_url_rewrites.has-error').text).to include "includes no captures"
                    end
                end

                feature 'when missing substitutions' do
                    scenario 'shows error' do
                        rules = "/articles\/[\w-]+\/(\d+)/:articles.php?id=\n"

                        fill_in 'URL rewrite rules', with: rules
                        submit

                        expect(find('.site_profile_scope_url_rewrites.has-error').text).to include "includes no substitutions"
                    end
                end

                feature 'when pattern is empty' do
                    scenario 'shows error' do
                        rules = ":articles.php?id=\1\n"

                        fill_in 'URL rewrite rules', with: rules
                        submit

                        expect(find('.site_profile_scope_url_rewrites.has-error').text).to include "cannot be empty"
                    end
                end

                feature 'when substitution is empty' do
                    scenario 'shows error' do
                        rules = "/articles\/[\w-]+\/(\d+)/:"

                        fill_in 'URL rewrite rules', with: rules
                        submit

                        expect(find('.site_profile_scope_url_rewrites.has-error').text).to include "cannot be empty"
                    end
                end

                feature 'when given invalid pattern' do
                    scenario 'shows error' do
                        rules = "/(articles\/[\w-]+\/(\d+)/:\1"

                        fill_in 'URL rewrite rules', with: rules
                        submit

                        expect(find('.site_profile_scope_url_rewrites.has-error').text).to include 'invalid pattern'
                    end
                end
            end

            feature 'Path template patterns' do
                scenario 'can be set' do
                    rules = "stuff\nblah"

                    fill_in 'Path template patterns', with: rules
                    submit

                    expect(profile.scope_template_path_patterns).to eq ([
                        'stuff', 'blah'
                    ])
                end

                feature 'when given invalid pattern' do
                    scenario 'shows error' do
                        fill_in 'Path template patterns', with: '(articles'
                        submit

                        expect(find('.site_profile_scope_template_path_patterns.has-error').text).to include 'invalid pattern'
                    end
                end
            end

            feature 'Parameter redundancy limit' do
                scenario 'can be set' do
                    fill_in 'Parameter redundancy limit', with: 10
                    submit

                    expect(profile.scope_auto_redundant_paths).to eq 10
                end
            end

            feature 'Path exclusion patterns' do
                scenario 'can be set' do
                    fill_in 'Path exclusion patterns', with: "test\\w+\ninclude this (.*)"
                    submit

                    expect(profile.scope_exclude_path_patterns).to eq [
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

                        expect(find('.site_profile_scope_exclude_path_patterns.has-error').text).to include exp
                    end
                end
            end

            feature 'Advanced' do
                scenario 'can set Extend paths' do
                    fill_in 'Extend paths', with: "test\ntest2"
                    submit

                    expect(profile.scope_extend_paths).to eq [ 'test', 'test2' ]
                end

                feature 'Content exclusion patterns' do
                    scenario 'can be set ' do
                        fill_in 'Content exclusion patterns', with: "test\\w+\ninclude this (.*)"
                        submit

                        expect(profile.scope_exclude_content_patterns).to eq [
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

                            expect(find('.site_profile_scope_exclude_content_patterns.has-error').text).to include exp
                        end
                    end
                end
            end
        end

        feature 'Audit' do
            feature 'Custom inputs' do
                scenario 'can be set' do
                    rules = "/input1\/(?<input1>\w+)\/input2\/(?<input2>\w+)/\n"
                    rules << "/input3\/(?<input3>\w+)\/input4\/(?<input4>\w+)/"

                    fill_in 'Custom inputs', with: rules
                    submit

                    expect(profile.audit_link_templates).to eq [
                        "/input1/(?<input1>w+)/input2/(?<input2>w+)/",
                        "/input3/(?<input3>w+)/input4/(?<input4>w+)/"
                    ]
                end

                feature 'when missing named captures' do
                    scenario 'shows error' do
                        rules = "/input1\/(\w+)\/input2\/(\w+)/\n"

                        fill_in 'Custom inputs', with: rules
                        submit

                        expect(find('.site_profile_audit_link_templates.has-error').text).to include "has no named captures"
                    end
                end

                feature 'when given invalid pattern' do
                    scenario 'shows error' do
                        rules = "(/input1\/(\w+)\/input2\/(\w+)/\n"

                        fill_in 'Custom inputs', with: rules
                        submit

                        expect(find('.site_profile_audit_link_templates.has-error').text).to include 'invalid pattern'
                    end
                end

            end
        end

        feature 'Fill-in values' do
            scenario 'can be set' do
                fill_in 'Fill-in values', with: "test=1\ntest2=2"
                submit

                expect(profile.input_values).to eq ({
                    'test'  => '1',
                    'test2' => '2'
                })
            end

            scenario 'sorts them by name' do
                profile.input_values = {
                    'b' => '1',
                    'a' => '2',
                    'c' => '0'
                }
                profile.save

                visit current_url

                expect(find('#site_profile_attributes_input_values').native.text).to eq "a=2\nb=1\nc=0"
            end

            feature 'when given invalid pattern' do
                scenario 'shows error' do
                    fill_in 'Fill-in values', with: '(test=33'
                    submit

                    expect(find('.site_profile_input_values.has-error').text).to include 'invalid pattern'
                end
            end
        end

        feature 'HTTP' do
            scenario 'can set Username' do
                fill_in 'Username', with: 'Stuff here'
                submit

                expect(profile.http_authentication_username).to eq 'Stuff here'
            end

            scenario 'can set Password' do
                fill_in 'Password', with: 'Stuff here'
                submit

                expect(profile.http_authentication_password).to eq 'Stuff here'
            end

            scenario 'can set Cookies' do
                fill_in 'Cookies', with: "cookie1=blah1\ncookie2=blah2"
                submit

                expect(profile.http_cookies).to eq ({
                    'cookie1' => 'blah1',
                    'cookie2' => 'blah2'
                })
            end

            scenario 'can set Headers' do
                fill_in 'Headers', with: "header1=blah1\nheader2=blah2"
                submit

                expect(profile.http_request_headers).to eq ({
                    'header1' => 'blah1',
                    'header2' => 'blah2'
                })
            end

            scenario 'can set Request concurrency' do
                fill_in 'Request concurrency', with: 100
                submit

                expect(profile.http_request_concurrency).to eq 100
            end
        end

        feature 'Platforms' do
            let(:platforms) { site.reload.profile.platforms }

            feature 'preset', js: true do
                before do
                    click_button button
                    submit_via_sidebar

                    expect(page).to have_content 'Site settings were successfully updated'
                end

                feature 'Linux, Apache, MySQL, PHP' do
                    let(:button) { 'Linux, Apache, MySQL, PHP' }

                    scenario 'sets Linux' do
                        expect(platforms).to include 'linux'
                    end

                    scenario 'sets Apache' do
                        expect(platforms).to include 'apache'
                    end

                    scenario 'sets MySQL' do
                        expect(platforms).to include 'mysql'
                    end

                    scenario 'sets PHP' do
                        expect(platforms).to include 'php'
                    end
                end

                feature 'Linux, Nginx, Postgresql, Ruby, Ruby on Rails' do
                    let(:button) { 'Linux, Nginx, Postgresql, Ruby, Ruby on Rails' }

                    scenario 'sets Linux' do
                        expect(platforms).to include 'linux'
                    end

                    scenario 'sets Nginx' do
                        expect(platforms).to include 'nginx'
                    end

                    scenario 'sets Postgresql' do
                        expect(platforms).to include 'pgsql'
                    end

                    scenario 'sets Ruby' do
                        expect(platforms).to include 'ruby'
                    end

                    scenario 'sets Ruby on Rails' do
                        expect(platforms).to include 'rails'
                    end
                end

                feature 'Linux, TomCat, Generic SQL family, Java' do
                    let(:button) { 'Linux, TomCat, Generic SQL family, Java' }

                    scenario 'sets Linux' do
                        expect(platforms).to include 'linux'
                    end

                    scenario 'sets TomCat' do
                        expect(platforms).to include 'tomcat'
                    end

                    scenario 'sets Generic SQL family' do
                        expect(platforms).to include 'sql'
                    end

                    scenario 'sets Java' do
                        expect(platforms).to include 'java'
                    end
                end

                feature 'MS Windows, IIS, MSSQL, ASP, ASP.NET' do
                    let(:button) { 'MS Windows, IIS, MSSQL, ASP, ASP.NET' }

                    scenario 'sets MS Windows' do
                        expect(platforms).to include 'windows'
                    end

                    scenario 'sets IIS' do
                        expect(platforms).to include 'iis'
                    end

                    scenario 'sets MSSQL' do
                        expect(platforms).to include 'mssql'
                    end

                    scenario 'sets ASP' do
                        expect(platforms).to include 'asp'
                    end

                    scenario 'sets ASP.NET' do
                        expect(platforms).to include 'aspx'
                    end
                end
            end

            feature 'Operating systems' do
                scenario 'can set Generic Unix family' do
                    check 'Generic Unix family'
                    submit

                    expect(profile.platforms).to include 'unix'
                end

                scenario 'can set Linux' do
                    check 'Linux'
                    submit

                    expect(profile.platforms).to include 'linux'
                end

                scenario 'can set Generic BSD family' do
                    check 'Generic BSD family'
                    submit

                    expect(profile.platforms).to include 'bsd'
                end

                scenario 'can set IBM AIX' do
                    check 'IBM AIX'
                    submit

                    expect(profile.platforms).to include 'aix'
                end

                scenario 'can set Solaris' do
                    check 'Solaris'
                    submit

                    expect(profile.platforms).to include 'solaris'
                end

                scenario 'can set MS Windows' do
                    check 'MS Windows'
                    submit

                    expect(profile.platforms).to include 'windows'
                end
            end

            feature 'Databases' do
                scenario 'can set Generic SQL family' do
                    check 'Generic SQL family'
                    submit

                    expect(profile.platforms).to include 'sql'
                end

                scenario 'can set MySQL' do
                    check 'MySQL'
                    submit

                    expect(profile.platforms).to include 'mysql'
                end

                scenario 'can set Postgresql' do
                    check 'Postgresql'
                    submit

                    expect(profile.platforms).to include 'pgsql'
                end

                scenario 'can set MSSQL' do
                    check 'MSSQL'
                    submit

                    expect(profile.platforms).to include 'mssql'
                end

                scenario 'can set Generic NoSQL family' do
                    check 'Generic NoSQL family'
                    submit

                    expect(profile.platforms).to include 'nosql'
                end

                scenario 'can set MongoDB' do
                    check 'MongoDB'
                    submit

                    expect(profile.platforms).to include 'mongodb'
                end
            end

            feature 'Web servers' do
                scenario 'can set Apache' do
                    check 'Apache'
                    submit

                    expect(profile.platforms).to include 'apache'
                end

                scenario 'can set IIS' do
                    check 'IIS'
                    submit

                    expect(profile.platforms).to include 'iis'
                end

                scenario 'can set Jetty' do
                    check 'Jetty'
                    submit

                    expect(profile.platforms).to include 'jetty'
                end

                scenario 'can set Nginx' do
                    check 'Nginx'
                    submit

                    expect(profile.platforms).to include 'nginx'
                end

                scenario 'can set TomCat' do
                    check 'TomCat'
                    submit

                    expect(profile.platforms).to include 'tomcat'
                end
            end

            feature 'Programming languages' do
                scenario 'can set ASP' do
                    check 'ASP'
                    submit

                    expect(profile.platforms).to include 'asp'
                end

                scenario 'can set ASP.NET' do
                    check 'ASP.NET'
                    submit

                    expect(profile.platforms).to include 'aspx'
                end

                scenario 'can set Java' do
                    check 'Java'
                    submit

                    expect(profile.platforms).to include 'java'
                end

                scenario 'can set Perl' do
                    check 'Perl'
                    submit

                    expect(profile.platforms).to include 'perl'
                end

                scenario 'can set PHP' do
                    check 'PHP'
                    submit

                    expect(profile.platforms).to include 'php'
                end

                scenario 'can set Python' do
                    check 'Python'
                    submit

                    expect(profile.platforms).to include 'python'
                end

                scenario 'can set Ruby' do
                    check 'Ruby'
                    submit

                    expect(profile.platforms).to include 'ruby'
                end
            end

            feature 'Frameworks' do
                scenario 'can set Rack' do
                    check 'Rack'
                    submit

                    expect(profile.platforms).to include 'rack'
                end
            end

            feature 'Advanced' do
                scenario 'can set Disable fingerprinting' do
                    check 'Disable fingerprinting'
                    submit

                    expect(profile.no_fingerprinting).to eq true
                end
            end
        end

        feature 'Browser' do
            feature 'Wait for elements to appear' do
                scenario 'can be set' do
                    rules = "stuff:#myElement\n"
                    rules << 'blah:#myOtherElement'

                    fill_in 'Wait for elements to appear', with: rules
                    submit

                    expect(profile.browser_cluster_wait_for_elements).to eq ({
                        'stuff' => '#myElement',
                        'blah'  => '#myOtherElement'
                    })
                end

                feature 'when missing the pattern' do
                    scenario 'shows error' do
                        fill_in 'Wait for elements to appear', with: ':2'
                        submit

                        expect(find('.site_profile_browser_cluster_wait_for_elements.has-error').text).to include 'pattern cannot be empty'
                    end
                end

                feature 'when missing the counter' do
                    scenario 'shows error' do
                        fill_in 'Wait for elements to appear', with: 'stuff:'
                        submit

                        expect(find('.site_profile_browser_cluster_wait_for_elements.has-error').text).to include 'is missing a CSS selector'
                    end
                end

                feature 'when given invalid pattern' do
                    scenario 'shows error' do
                        fill_in 'Wait for elements to appear', with: '(stuff:#myElement'
                        submit

                        expect(find('.site_profile_browser_cluster_wait_for_elements.has-error').text).to include 'invalid pattern'
                    end
                end
            end

            scenario 'can set Do not load images' do
                check 'Do not load images'
                submit

                expect(profile.browser_cluster_ignore_images).to be true
            end
        end
    end
end
