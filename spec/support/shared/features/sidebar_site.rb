shared_examples_for 'Site sidebar' do |options = {}|
    let(:site_sidebar) { find '#sidebar #sidebar-site' }
    let(:site_sidebar_buttons) { site_sidebar.find '.btn-group' }
    let(:site_sidebar_heading) { site_sidebar.find 'h4' }

    scenario 'includes external link to site' do
        expect(site_sidebar_heading).to have_xpath "//a[@href='#{site.url}']"
    end

    scenario 'includes internal link to site with filtering options' do
        expect(site_sidebar_heading).to have_xpath "a[starts-with(@href, '#{site_path( site )}?filter')]"
    end

    if !options[:without_buttons]

        let(:site_sidebar_selected_button){ [super()].flatten }

        scenario 'selects sidebar button', js: false do
            btn = site_sidebar_buttons.find( *site_sidebar_selected_button )
            expect(btn[:class]).to include 'btn-selected'
        end

        feature 'buttons', js: false do
            scenario 'includes site overview button with filtering options' do
                xpath = "a[starts-with(@href, '#{site_path( site )}?filter') and not(@data-method)]"
                expect(site_sidebar_heading).to have_xpath xpath

                btn = site_sidebar_buttons.find( :xpath, xpath )
                expect(btn).to have_css 'i.fa.fa-home'
            end

            scenario 'includes scans button' do
                expect(site_sidebar_buttons).to have_xpath "a[@href='#{site_scans_path(site)}']"

                btn = site_sidebar_buttons.find( "a[@href='#{site_scans_path(site)}']" )
                expect(btn).to have_css 'i.fa.fa-tasks'
            end

            scenario 'includes link to user roles' do
                expect(site_sidebar_buttons).to have_xpath "a[@href='#{site_roles_path(site)}']"

                btn = site_sidebar_buttons.find( "a[@href='#{site_roles_path(site)}']" )
                expect(btn).to have_css 'i.fa.fa-users'
            end

            scenario 'includes link to settings' do
                expect(site_sidebar_buttons).to have_xpath "a[@href='#{edit_site_path(site)}']"

                btn = site_sidebar_buttons.find( "a[@href='#{edit_site_path(site)}']" )
                expect(btn).to have_css 'i.fa.fa-cog'
            end

            scenario 'includes delete link' do
                expect(site_sidebar_buttons).to have_xpath "a[@href='#{site_path(site)}' and @data-method='delete']"

                btn = site_sidebar_buttons.find( :xpath, "a[@href='#{site_path(site)}' and @data-method='delete']" )
                expect(btn).to have_css 'i.fa.fa-trash'
            end
        end
    end
end
