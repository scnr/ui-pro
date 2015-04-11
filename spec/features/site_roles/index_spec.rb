include Warden::Test::Helpers
Warden.test_mode!

feature 'Site roles index page', js: true do

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
        visit site_path( site )

        click_link 'Roles'
    end

    scenario 'can be visited by URL fragment' do
        visit "#{site_path( site )}#!/roles"
        expect(find('h2')).to have_content 'User roles'
    end

    scenario 'user sees heading' do
        expect(find('h2')).to have_content 'User roles'
    end

    scenario 'user sees New button in heading' do
        find('h2').find( :xpath, "//a[@href='#!/roles/new']" ).click
        expect(page).to have_css 'form#new_site_role'
    end

    feature 'table' do
        let(:table) { find '#roles table' }

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
            find( :xpath, "//a[@href='#!/roles/#{subject.id}/edit']" ).click
            expect(page).to have_css "form#edit_site_role_#{subject.id}"
        end

        feature 'when there are no associated scans' do
            scenario 'has delete button' do
                find(:xpath, "//a[@href='#{site_role_path( site, subject )}' and @data-method='delete']" ).click
                expect(table).to_not have_content subject.name
            end
        end

        feature 'when there are associated scans' do
            scenario 'does not have delete button' do
                subject.scans << scan
                subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

                visit "#{site_path( site )}#!/roles"

                expect(page).to_not have_xpath "//a[@href='#{site_role_path( site, subject )}' and @data-method='delete']"
            end
        end
    end
end
