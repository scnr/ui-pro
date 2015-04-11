include Warden::Test::Helpers
Warden.test_mode!

feature 'Edit site role page', js: true do

    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }

    let(:site_role) { FactoryGirl.create :site_role, site: site }
    let(:new_role) { site.reload.roles.last }

    after(:each) do
        Warden.test_reset!
    end

    before do
        site_role
        user.sites << site

        login_as( user, scope: :user )
        visit site_path( site )

        click_link 'Roles'
        find( :xpath, "//a[@href='#!/roles/1/edit']" ).click
    end

    def submit
        find( :xpath, "//input[@type='submit']" ).click
        sleep 1
    end

    scenario 'can be visited by URL fragment' do
        visit "#{site_path( site )}#!/roles/1/edit"

        expect(page).to have_css 'form#edit_site_role_1'
    end

    scenario 'can update the role' do
        fill_in 'site_role_name', with: 'My new name'

        submit

        expect(new_role.name).to eq 'My new name'
    end

end
