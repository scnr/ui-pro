feature 'Site profile form' do
    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site }
    let(:profile) { FactoryGirl.create :profile }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: FactoryGirl.create( :profile ) }
    let(:revision) { FactoryGirl.create :revision, scan: scan }

    before do
        revision
        user.sites << site

        login_as user, scope: :user
        visit site_path( site )
    end

    after(:each) do
        Warden.test_reset!
    end

    def submit
        find( :xpath, "//input[@type='submit']" ).click
    end

    let(:profile) { site.reload.profile }

    scenario 'sees profile form' do
        expect(find('.profile-form')).to be_truthy
    end

    scenario 'can submit form using sidebar button', js: true do
        click_link 'Settings'
        fill_in 'Parameter redundancy limit', with: 10

        find('#sidebar button').click
        sleep 1

        expect(profile.scope_auto_redundant_paths).to eq 10
    end

    feature 'option' do
        feature 'Scope' do
            scenario 'can set Only follow HTTPS URLs' do
                check 'Only follow HTTPS URLs'
                submit

                expect(profile.scope_https_only).to eq true
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

            feature 'Path redundancy patterns' do
                scenario 'can be set' do
                    rules = "stuff:3\n"
                    rules << 'blah:4'

                    fill_in 'Path redundancy patterns', with: rules
                    submit

                    expect(profile.scope_redundant_path_patterns).to eq ({
                        'stuff' => '3',
                        'blah'  => '4'
                    })
                end

                feature 'when missing the pattern' do
                    scenario 'shows error' do
                        fill_in 'Path redundancy patterns', with: ':2'
                        submit

                        expect(find('.site_profile_scope_redundant_path_patterns.has-error').text).to include "pattern cannot be empty"
                    end
                end

                feature 'when missing the counter' do
                    scenario 'shows error' do
                        fill_in 'Path redundancy patterns', with: "stuff:"
                        submit

                        expect(find('.site_profile_scope_redundant_path_patterns.has-error').text).to include "needs an integer counter greater than 0"
                    end
                end

                feature 'when given invalid pattern' do
                    scenario 'shows error' do
                        fill_in 'Path redundancy patterns', with: '(articles:1'
                        submit

                        expect(find('.site_profile_scope_redundant_path_patterns.has-error').text).to include 'invalid pattern'
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

            feature 'when given invalid pattern' do
                scenario 'shows error' do
                    fill_in 'Fill-in values', with: '(test=33'
                    submit

                    expect(find('.site_profile_input_values.has-error').text).to include 'invalid pattern'
                end
            end

        end

        feature 'HTTP' do
            feature 'Advanced' do
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
        end

        feature 'Platforms' do
            feature 'preset' do
                feature 'Linux, Apache, MySQL, PHP' do
                    scenario 'sets Linux'
                    scenario 'sets Apache'
                    scenario 'sets MySQL'
                    scenario 'sets PHP'
                end

                feature 'Linux, Nginx, Postgresql, Ruby, Rack' do
                    scenario 'sets Linux'
                    scenario 'sets Nginx'
                    scenario 'sets Postgresql'
                    scenario 'sets Ruby'
                    scenario 'sets Rack'
                end

                feature 'Linux, TomCat, Generic SQL family, JSP' do
                    scenario 'sets Linux'
                    scenario 'sets TomCat'
                    scenario 'sets Generic SQL family'
                    scenario 'sets JSP'
                end

                feature 'MS Windows, IIS, MSSQL, ASP, ASP.NET' do
                    scenario 'sets MS Windows'
                    scenario 'sets IIS'
                    scenario 'sets MSSQL'
                    scenario 'sets ASP'
                    scenario 'sets ASP.NET'
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

                scenario 'can set JSP' do
                    check 'JSP'
                    submit

                    expect(profile.platforms).to include 'jsp'
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
    end
end
