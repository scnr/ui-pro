include Warden::Test::Helpers
Warden.test_mode!

feature 'Show site role page' do
    subject { FactoryGirl.create :site_role, site: site }
    let(:new_role) { site.reload.roles.last }
    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site }

    after(:each) do
        Warden.test_reset!
    end

    before do
        subject
        user.sites << site

        login_as( user, scope: :user )
        refresh
    end

    def refresh
        visit site_role_path( site, subject )
    end

    let(:site_sidebar_selected_button) { "a[@href='#{site_roles_path(site)}']" }
    it_behaves_like 'Site sidebar'
    it_behaves_like 'Roles sidebar'

    let(:with_scans) { subject }
    it_behaves_like 'Scans sidebar'

    scenario 'sees name in heading' do
        expect(find('h2')).to have_content subject.name
    end

    scenario 'sees rendered Markdown description' do
        subject.description = '**Stuff**'
        subject.save

        refresh

        expect(find('.description strong')).to have_content 'Stuff'
    end

    feature 'when role is Guest' do
        before do
            subject.scans = []
            subject.login_type = 'none'
            subject.save

            refresh
        end

        scenario 'does not have edit link' do
            expect(page).to_not have_xpath "//a[@href='#{edit_site_role_path( site, subject )}']"
        end

        scenario 'does not have delete link' do
            expect(page).to_not have_xpath "//a[@href='#{site_role_path( site, subject )}' and @data-method='delete']"
        end

        scenario 'shows alert about missing login info' do
            expect(find('#role-guest .alert.alert-info')).to have_content 'Guest role has no login info'
        end
    end

    feature 'when role is not Guest' do
        scenario 'has edit link' do
            expect(page).to have_xpath "//a[@href='#{edit_site_role_path( site, subject )}']"
        end

        feature 'when there are no associated scans' do
            before do
                subject.scans = []
                subject.save

                refresh
            end

            scenario 'has delete button' do
                expect(page).to have_xpath "//a[@href='#{site_role_path( site, subject )}' and @data-method='delete']"
            end

            scenario 'does not list associated scans' do
                expect(page).to_not have_css '#site-role-scans'
            end
        end

        feature 'when there are associated scans' do
            before do
                subject.scans << scan
                subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

                refresh
            end

            scenario 'does not have delete button' do
                expect(page).to_not have_xpath "//a[@href='#{site_role_path( site, subject )}' and @data-method='delete']"
            end
        end

        feature 'session' do
            let(:session) { find '#site-role-session' }

            scenario 'sees logout exclusion patterns' do
                subject.scope_exclude_path_patterns.each do |pattern|
                    expect(session).to have_content pattern
                end
            end

            scenario 'sees check URL' do
                expect(session).to have_content subject.session_check_url
            end

            scenario 'sees check pattern' do
                expect(session).to have_content subject.session_check_pattern
            end
        end

        feature 'login' do
            let(:login) { find '#site-role-login' }

            feature 'when type is' do
                feature 'form' do
                    let(:parameters) { login.find('table') }

                    before do
                        subject.login_type = 'form'
                        subject.save
                        refresh
                    end

                    scenario 'sees form URL' do
                        expect(login).to have_content subject.login_form_url
                    end

                    scenario 'sees form parameters' do
                        subject.login_form_parameters.each do |name, value|
                            expect(parameters).to have_content name
                            expect(parameters).to have_content value
                        end
                    end
                end

                feature 'script' do
                    before do
                        subject.login_type = 'script'
                        subject.save
                        refresh
                    end

                    scenario 'sees script code' do
                        expect(login).to have_css 'table.CodeRay'
                    end
                end
            end
        end
    end
end
