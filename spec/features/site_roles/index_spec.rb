include Warden::Test::Helpers
Warden.test_mode!

feature 'Site roles index page' do

    subject { FactoryGirl.create :site_role, name: 'Stuff', site: site }
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
        visit site_roles_path( site )
    end

    let(:site_sidebar_selected_button) { "a[@href='#{current_path}']" }
    it_behaves_like 'Site sidebar'

    scenario 'user sees heading' do
        expect(find('h1')).to have_content 'User roles'
    end

    scenario 'user sees New button in heading' do
        expect(find('h1')).to have_xpath "//a[@href='#{new_site_role_path( site )}']"
    end

    feature 'table' do
        let(:table) { find '#roles-table' }

        scenario 'has show link' do
            click_link subject.name
            expect(page).to have_content subject.session_check_url
        end

        scenario 'has name' do
            expect(table).to have_content subject.name
        end

        scenario 'has login type' do
            expect(table).to have_content subject.login_type
        end

        scenario 'has amount of scans' do
            expect(table).to have_content subject.scans.size
        end

        scenario 'has edit link' do
            expect(table).to have_xpath "//a[@href='#{edit_site_role_path( site, subject )}']"
        end

        feature 'when there are no associated scans' do
            scenario 'has delete button' do
                expect(table).to have_xpath "//a[@href='#{site_role_path( site, subject )}' and @data-method='delete']"
            end
        end

        feature 'when there are associated scans' do
            scenario 'does not have delete button' do
                subject.scans << scan
                subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

                visit current_url

                expect(page).to_not have_xpath "//a[@href='#{site_role_path( site, subject )}' and @data-method='delete']"
            end
        end
    end
end
