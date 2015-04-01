include Warden::Test::Helpers
Warden.test_mode!

feature 'Profile new page', :devise do

    subject { FactoryGirl.create :profile, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        before do
            user.profiles << subject

            login_as( user, scope: :user )
            visit new_profile_path
        end

        scenario 'sees profile form' do
            expect(find('h1')).to be_truthy
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

                    click_button 'Create Profile'

                    expect(Profile.last.name).to eq 'My name'
                end

                scenario 'is mandatory' do
                    fill_in 'profile_name', with: ''
                    fill_in 'profile_description', with: 'My description'

                    click_button 'Create Profile'

                    expect(find('.profile_name.has-error').text).to include "can't be blank"
                end
            end

            feature 'Description' do
                scenario 'can be set' do
                    fill_in 'profile_name', with: 'My name'
                    fill_in 'profile_description', with: 'My description'

                    click_button 'Create Profile'

                    expect(Profile.last.description).to eq 'My description'
                end

                scenario 'is mandatory' do
                    fill_in 'profile_name', with: 'My name'
                    fill_in 'profile_description', with: ''

                    click_button 'Create Profile'

                    expect(find('.profile_description.has-error').text).to include "can't be blank"
                end
            end

            feature 'Scope' do
                scenario 'can set Page limit' do
                    fill_in 'Page limit', with: '10'
                    click_button 'Create Profile'

                    expect(Profile.last.scope_page_limit).to eq 10
                end

                scenario 'can set Directory depth limit' do
                    fill_in 'Page limit', with: '10'
                    click_button 'Create Profile'

                    expect(Profile.last.scope_page_limit).to eq 10
                end

                feature 'Path inclusion patterns' do
                    scenario 'can be set' do
                        fill_in 'Path inclusion patterns', with: "test\\w+\ninclude this (.*)"
                        click_button 'Create Profile'

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
                            click_button 'Create Profile'

                            expect(find('.profile_scope_include_path_patterns.has-error').text).to include exp
                        end
                    end
                end

                feature 'Path exclusion patterns' do
                    scenario 'can be set' do
                        fill_in 'Path exclusion patterns', with: "test\\w+\ninclude this (.*)"
                        click_button 'Create Profile'

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
                            click_button 'Create Profile'

                            expect(find('.profile_scope_exclude_path_patterns.has-error').text).to include exp
                        end
                    end
                end

                feature 'Advanced' do
                    scenario 'can set Ignore binary content' do
                        check 'Ignore binary content'
                        click_button 'Create Profile'

                        expect(Profile.last.scope_exclude_binaries).to eq true
                    end

                    scenario 'can set Only follow HTTPS URLs' do
                        check 'Only follow HTTPS URLs'
                        click_button 'Create Profile'

                        expect(Profile.last.scope_https_only).to eq true
                    end

                    scenario 'can set DOM depth limit' do
                        fill_in 'DOM depth limit', with: '10'
                        click_button 'Create Profile'

                        expect(Profile.last.scope_dom_depth_limit).to eq 10
                    end

                    feature 'Content exclusion patterns' do
                        scenario 'can be set ' do
                            fill_in 'Content exclusion patterns', with: "test\\w+\ninclude this (.*)"
                            click_button 'Create Profile'

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
                                click_button 'Create Profile'

                                expect(find('.profile_scope_exclude_content_patterns.has-error').text).to include exp
                            end
                        end
                    end

                    feature 'URL rewrite rules' do
                        scenario 'can be set' do
                            rules = "/articles\/[\w-]+\/(\d+)/:articles.php?id=\\1\n"
                            rules << "/photos\/[\w-]+\/(\d+)/:photos.php?id=\\1"

                            fill_in 'URL rewrite rules', with: rules
                            click_button 'Create Profile'

                            expect(Profile.last.scope_url_rewrites).to eq ({
                                '/articles/[w-]+/(d+)/' => 'articles.php?id=\1',
                                '/photos/[w-]+/(d+)/'   => 'photos.php?id=\1'
                            })
                        end

                        feature 'when missing captures' do
                            scenario 'shows error' do
                                rules = "/articles\/[\w-]+\/\d+/:articles.php?id=\1\n"

                                fill_in 'URL rewrite rules', with: rules
                                click_button 'Create Profile'

                                expect(find('.profile_scope_url_rewrites.has-error').text).to include "includes no captures"
                            end
                        end

                        feature 'when missing substitutions' do
                            scenario 'shows error' do
                                rules = "/articles\/[\w-]+\/(\d+)/:articles.php?id=\n"

                                fill_in 'URL rewrite rules', with: rules
                                click_button 'Create Profile'

                                expect(find('.profile_scope_url_rewrites.has-error').text).to include "includes no substitutions"
                            end
                        end

                        feature 'when pattern is empty' do
                            scenario 'shows error' do
                                rules = ":articles.php?id=\1\n"

                                fill_in 'URL rewrite rules', with: rules
                                click_button 'Create Profile'

                                expect(find('.profile_scope_url_rewrites.has-error').text).to include "cannot be empty"
                            end
                        end

                        feature 'when substitution is empty' do
                            scenario 'shows error' do
                                rules = "/articles\/[\w-]+\/(\d+)/:"

                                fill_in 'URL rewrite rules', with: rules
                                click_button 'Create Profile'

                                expect(find('.profile_scope_url_rewrites.has-error').text).to include "cannot be empty"
                            end
                        end

                        feature 'when given invalid pattern' do
                            scenario 'shows error' do
                                rules = "/(articles\/[\w-]+\/(\d+)/:\1"

                                fill_in 'URL rewrite rules', with: rules
                                click_button 'Create Profile'

                                expect(find('.profile_scope_url_rewrites.has-error').text).to include 'invalid pattern'
                            end
                        end
                    end

                    scenario 'can set Extend paths' do
                        fill_in 'Extend paths', with: "test\ntest2"
                        click_button 'Create Profile'

                        expect(Profile.last.scope_extend_paths).to eq [
                            'test', 'test2'
                        ]
                    end

                    scenario 'can set Restrict paths' do
                        fill_in 'Restrict paths', with: "test\ntest2"
                        click_button 'Create Profile'

                        expect(Profile.last.scope_restrict_paths).to eq [
                            'test', 'test2'
                        ]
                    end

                    feature 'Path redundancy patterns' do
                        scenario 'can be set' do
                            rules = "stuff:3\n"
                            rules << 'blah:4'

                            fill_in 'Path redundancy patterns', with: rules
                            click_button 'Create Profile'

                            expect(Profile.last.scope_redundant_path_patterns).to eq ({
                                'stuff' => '3',
                                'blah'  => '4'
                            })
                        end

                        feature 'when missing the pattern' do
                            scenario 'shows error' do
                                fill_in 'Path redundancy patterns', with: ':2'
                                click_button 'Create Profile'

                                expect(find('.profile_scope_redundant_path_patterns.has-error').text).to include "pattern cannot be empty"
                            end
                        end

                        feature 'when missing the counter' do
                            scenario 'shows error' do
                                fill_in 'Path redundancy patterns', with: "stuff:"
                                click_button 'Create Profile'

                                expect(find('.profile_scope_redundant_path_patterns.has-error').text).to include "needs an integer counter greater than 0"
                            end
                        end

                        feature 'when given invalid pattern' do
                            scenario 'shows error' do
                                fill_in 'Path redundancy patterns', with: '(articles:1'
                                click_button 'Create Profile'

                                expect(find('.profile_scope_redundant_path_patterns.has-error').text).to include 'invalid pattern'
                            end
                        end
                    end

                    feature 'Parameter redundancy limit' do
                        scenario 'can be set' do
                            fill_in 'Parameter redundancy limit', with: 10
                            click_button 'Create Profile'

                            expect(Profile.last.scope_auto_redundant_paths).to eq 10
                        end
                    end
                end
            end

            feature 'Audit' do
                scenario 'can set Audit forms' do
                    check 'Audit forms'
                    click_button 'Create Profile'

                    expect(Profile.last.audit_forms).to eq true
                end

                scenario 'can set Audit links' do
                    check 'Audit links'
                    click_button 'Create Profile'

                    expect(Profile.last.audit_links).to eq true
                end

                scenario 'can set Audit cookies' do
                    check 'Audit cookies'
                    click_button 'Create Profile'

                    expect(Profile.last.audit_cookies).to eq true
                end

                scenario 'can set Audit headers' do
                    check 'Audit headers'
                    click_button 'Create Profile'

                    expect(Profile.last.audit_headers).to eq true
                end

                scenario 'can set Audit JSON inputs' do
                    check 'Audit JSON inputs'
                    click_button 'Create Profile'

                    expect(Profile.last.audit_jsons).to eq true
                end

                scenario 'can set Audit XML inputs' do
                    check 'Audit XML inputs'
                    click_button 'Create Profile'

                    expect(Profile.last.audit_xmls).to eq true
                end

                feature 'Advanced' do
                    scenario 'can set Audit with both http methods' do
                        check 'Audit with both http methods'
                        click_button 'Create Profile'

                        expect(Profile.last.audit_with_both_http_methods).to eq true
                    end

                    scenario 'can set Audit cookies extensively' do
                        check 'Audit cookies extensively'
                        click_button 'Create Profile'

                        expect(Profile.last.audit_cookies_extensively).to eq true
                    end

                    scenario 'can set Audit with extra parameter' do
                        check 'Audit with extra parameter'
                        click_button 'Create Profile'

                        expect(Profile.last.audit_with_extra_parameter).to eq true
                    end

                    scenario 'can set Audit parameter names' do
                        check 'Audit parameter names'
                        click_button 'Create Profile'

                        expect(Profile.last.audit_parameter_names).to eq true
                    end

                    feature 'Parameter exclusion patterns' do
                        scenario 'can be set' do
                            fill_in 'Parameter exclusion patterns', with: "test\ntest2"
                            click_button 'Create Profile'

                            expect(Profile.last.audit_exclude_vector_patterns).to eq [
                                'test', 'test2'
                            ]
                        end

                        feature 'when given invalid pattern' do
                            scenario 'shows error' do
                                fill_in 'Parameter exclusion patterns', with: '(articles'
                                click_button 'Create Profile'

                                expect(find('.profile_audit_exclude_vector_patterns.has-error').text).to include 'invalid pattern'
                            end
                        end
                    end

                    feature 'Parameter inclusion patterns' do
                        scenario 'can be set' do
                            fill_in 'Parameter inclusion patterns', with: "test\ntest2"
                            click_button 'Create Profile'

                            expect(Profile.last.audit_include_vector_patterns).to eq [
                                'test', 'test2'
                            ]
                        end

                        feature 'when given invalid pattern' do
                            scenario 'shows error' do
                                fill_in 'Parameter inclusion patterns', with: '(articles'
                                click_button 'Create Profile'

                                expect(find('.profile_audit_include_vector_patterns.has-error').text).to include 'invalid pattern'
                            end
                        end
                    end

                    feature 'Link templates' do
                        scenario 'can be set' do
                            rules = "/input1\/(?<input1>\w+)\/input2\/(?<input2>\w+)/\n"
                            rules << "/input3\/(?<input3>\w+)\/input4\/(?<input4>\w+)/"

                            fill_in 'Link templates', with: rules
                            click_button 'Create Profile'

                            expect(Profile.last.audit_link_templates).to eq [
                                "/input1/(?<input1>w+)/input2/(?<input2>w+)/",
                                "/input3/(?<input3>w+)/input4/(?<input4>w+)/"
                            ]
                        end

                        feature 'when missing named captures' do
                            scenario 'shows error' do
                                rules = "/input1\/(\w+)\/input2\/(\w+)/\n"

                                fill_in 'Link templates', with: rules
                                click_button 'Create Profile'

                                expect(find('.profile_audit_link_templates.has-error').text).to include "has no named captures"
                            end
                        end

                        feature 'when given invalid pattern' do
                            scenario 'shows error' do
                                rules = "(/input1\/(\w+)\/input2\/(\w+)/\n"

                                fill_in 'Link templates', with: rules
                                click_button 'Create Profile'

                                expect(find('.profile_audit_link_templates.has-error').text).to include 'invalid pattern'
                            end
                        end

                    end
                end
            end

            feature 'Input values' do
                scenario 'can be set' do
                    fill_in 'Input values', with: "test=1\ntest2=2"
                    click_button 'Create Profile'

                    expect(Profile.last.input_values).to eq ({
                        'test'  => '1',
                        'test2' => '2'
                    })
                end

                feature 'when given invalid pattern' do
                    scenario 'shows error' do
                        fill_in 'Input values', with: '(test=33'
                        click_button 'Create Profile'

                        expect(find('.profile_input_values.has-error').text).to include 'invalid pattern'
                    end
                end

            end

            feature 'HTTP' do
                scenario 'can set User-agent' do
                    fill_in 'User-agent', with: 'Stuff here'
                    click_button 'Create Profile'

                    expect(Profile.last.http_user_agent).to eq 'Stuff here'
                end

                scenario 'can set Username' do
                    fill_in 'Username', with: 'Stuff here'
                    click_button 'Create Profile'

                    expect(Profile.last.http_authentication_username).to eq 'Stuff here'
                end

                scenario 'can set Password' do
                    fill_in 'Password', with: 'Stuff here'
                    click_button 'Create Profile'

                    expect(Profile.last.http_authentication_password).to eq 'Stuff here'
                end

                scenario 'can set Proxy host' do
                    fill_in 'Proxy host', with: 'stuff.com'
                    click_button 'Create Profile'

                    expect(Profile.last.http_proxy_host).to eq 'stuff.com'
                end

                scenario 'can set Proxy port' do
                    fill_in 'Proxy port', with: '8080'
                    click_button 'Create Profile'

                    expect(Profile.last.http_proxy_port).to eq 8080
                end

                scenario 'can set Proxy username' do
                    fill_in 'Proxy username', with: 'blah'
                    click_button 'Create Profile'

                    expect(Profile.last.http_proxy_username).to eq 'blah'
                end

                scenario 'can set Proxy password' do
                    fill_in 'Proxy password', with: 'blah'
                    click_button 'Create Profile'

                    expect(Profile.last.http_proxy_password).to eq 'blah'
                end

                feature 'Advanced' do
                    scenario 'can set Cookies' do
                        fill_in 'Cookies', with: "cookie1=blah1\ncookie2=blah2"
                        click_button 'Create Profile'

                        expect(Profile.last.http_cookies).to eq ({
                            'cookie1' => 'blah1',
                            'cookie2' => 'blah2'
                        })
                    end

                    scenario 'can set Headers' do
                        fill_in 'Headers', with: "header1=blah1\nheader2=blah2"
                        click_button 'Create Profile'

                        expect(Profile.last.http_request_headers).to eq ({
                            'header1' => 'blah1',
                            'header2' => 'blah2'
                        })
                    end

                    scenario 'can set Request queue size' do
                        fill_in 'Request queue size', with: 20
                        click_button 'Create Profile'

                        expect(Profile.last.http_request_queue_size).to eq 20
                    end

                    scenario 'can set Request timeout' do
                        fill_in 'Request timeout', with: 2000
                        click_button 'Create Profile'

                        expect(Profile.last.http_request_timeout).to eq 2000
                    end

                    scenario 'can set Redirect limit' do
                        fill_in 'Redirect limit', with: 10
                        click_button 'Create Profile'

                        expect(Profile.last.http_request_redirect_limit).to eq 10
                    end

                    scenario 'can set Request concurrency' do
                        fill_in 'Request concurrency', with: 100
                        click_button 'Create Profile'

                        expect(Profile.last.http_request_concurrency).to eq 100
                    end

                    scenario 'can set Maximum response size' do
                        fill_in 'Maximum response size', with: 1000
                        click_button 'Create Profile'

                        expect(Profile.last.http_response_max_size).to eq 1000
                    end
                end

                feature 'Platforms' do
                    feature 'Operating systems' do
                        scenario 'can set Generic Unix family' do
                            check 'Generic Unix family'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'unix'
                        end

                        scenario 'can set Linux' do
                            check 'Linux'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'linux'
                        end

                        scenario 'can set Generic BSD family' do
                            check 'Generic BSD family'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'bsd'
                        end

                        scenario 'can set IBM AIX' do
                            check 'IBM AIX'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'aix'
                        end

                        scenario 'can set Solaris' do
                            check 'Solaris'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'solaris'
                        end

                        scenario 'can set MS Windows' do
                            check 'MS Windows'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'windows'
                        end
                    end

                    feature 'Databases' do
                        scenario 'can set Generic SQL family' do
                            check 'Generic SQL family'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'sql'
                        end

                        scenario 'can set MySQL' do
                            check 'MySQL'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'mysql'
                        end

                        scenario 'can set Postgresql' do
                            check 'Postgresql'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'pgsql'
                        end

                        scenario 'can set MSSQL' do
                            check 'MSSQL'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'mssql'
                        end

                        scenario 'can set Oracle' do
                            check 'Oracle'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'oracle'
                        end

                        scenario 'can set SQLite' do
                            check 'SQLite'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'sqlite'
                        end

                        scenario 'can set IngresDB' do
                            check 'IngresDB'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'ingres'
                        end

                        scenario 'can set EMC' do
                            check 'EMC'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'emc'
                        end

                        scenario 'can set DB2' do
                            check 'DB2'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'db2'
                        end

                        scenario 'can set InterBase' do
                            check 'InterBase'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'interbase'
                        end

                        scenario 'can set Informix' do
                            check 'Informix'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'informix'
                        end

                        scenario 'can set Firebird' do
                            check 'Firebird'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'firebird'
                        end

                        scenario 'can set SaP Max DB' do
                            check 'SaP Max DB'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'maxdb'
                        end

                        scenario 'can set Sybase' do
                            check 'Sybase'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'sybase'
                        end

                        scenario 'can set Frontbase' do
                            check 'Frontbase'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'frontbase'
                        end

                        scenario 'can set HSQLDB' do
                            check 'HSQLDB'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'hsqldb'
                        end

                        scenario 'can set MS Access' do
                            check 'MS Access'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'access'
                        end

                        scenario 'can set Generic NoSQL family' do
                            check 'Generic NoSQL family'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'nosql'
                        end

                        scenario 'can set MongoDB' do
                            check 'MongoDB'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'mongodb'
                        end
                    end

                    feature 'Web servers' do
                        scenario 'can set Apache' do
                            check 'Apache'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'apache'
                        end

                        scenario 'can set IIS' do
                            check 'IIS'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'iis'
                        end

                        scenario 'can set Jetty' do
                            check 'Jetty'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'jetty'
                        end

                        scenario 'can set Nginx' do
                            check 'Nginx'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'nginx'
                        end

                        scenario 'can set TomCat' do
                            check 'TomCat'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'tomcat'
                        end
                    end

                    feature 'Programming languages' do
                        scenario 'can set ASP' do
                            check 'ASP'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'asp'
                        end

                        scenario 'can set ASP.NET' do
                            check 'ASP.NET'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'aspx'
                        end

                        scenario 'can set JSP' do
                            check 'JSP'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'jsp'
                        end

                        scenario 'can set Perl' do
                            check 'Perl'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'perl'
                        end

                        scenario 'can set PHP' do
                            check 'PHP'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'php'
                        end

                        scenario 'can set Python' do
                            check 'Python'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'python'
                        end

                        scenario 'can set Ruby' do
                            check 'Ruby'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'ruby'
                        end
                    end

                    feature 'Frameworks' do
                        scenario 'can set Rack' do
                            check 'Rack'
                            click_button 'Create Profile'

                            expect(Profile.last.platforms).to include 'rack'
                        end
                    end
                end

                feature 'Advanced' do
                    scenario 'can set Disable fingerprinting' do
                        check 'Disable fingerprinting'
                        click_button 'Create Profile'

                        expect(Profile.last.no_fingerprinting).to eq true
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
