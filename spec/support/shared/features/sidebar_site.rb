shared_examples_for 'Site sidebar' do |options = {}|
    let(:site_sidebar) { find '#sidebar #sidebar-site' }
    let(:site_sidebar_heading) { site_sidebar.find 'h4' }

    scenario 'includes external link to site' do
        expect(site_sidebar_heading).to have_xpath "//a[@href='#{site.url}']"
    end

    scenario 'includes internal link to site with filtering options' do
        expect(site_sidebar_heading).to have_xpath "a[starts-with(@href, '#{site_path( site )}?filter')]"
    end

    if !options[:without_buttons]
        feature 'buttons', js: false do
            scenario 'includes new scan button' do
                expect(site_sidebar).to have_xpath "a[@href='#{new_site_scan_path(site)}']"

                btn = site_sidebar.find( "a[@href='#{new_site_scan_path(site)}']" )
                expect(btn).to have_css 'i.fa.fa-plus'
            end

            scenario 'includes link to user roles' do
                expect(site_sidebar).to have_xpath "a[@href='#{site_roles_path(site)}']"

                btn = site_sidebar.find( "a[@href='#{site_roles_path(site)}']" )
                expect(btn).to have_css 'i.fa.fa-users'
            end

            scenario 'includes link to settings' do
                expect(site_sidebar).to have_xpath "a[@href='#{edit_site_path(site)}']"

                btn = site_sidebar.find( "a[@href='#{edit_site_path(site)}']" )
                expect(btn).to have_css 'i.fa.fa-cog'
            end

            scenario 'includes delete link' do
                expect(site_sidebar).to have_xpath "a[@href='#{site_path(site)}' and @data-method='delete']"

                btn = site_sidebar.find( :xpath, "a[@href='#{site_path(site)}' and @data-method='delete']" )
                expect(btn).to have_css 'i.fa.fa-trash'
            end
        end
    end
end
