include Warden::Test::Helpers
Warden.test_mode!

feature 'Edit site role page' do
    subject { FactoryGirl.create :site_role, site: site }
    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    before do
        subject
        user.sites << site

        login_as( user, scope: :user )
        visit edit_site_role_path( site, subject )
    end

    def submit
        find( '#sidebar button' ).click
        sleep 1
    end

    let(:site_sidebar_selected_button) { "a[@href='#{site_roles_path(site)}']" }
    it_behaves_like 'Site sidebar'
    it_behaves_like 'Roles sidebar'

    let(:with_scans) { subject }
    it_behaves_like 'Scans sidebar'

    scenario 'can update the role', js: true do
        fill_in 'site_role_name', with: 'My new name'

        submit

        expect(subject.reload.name).to eq 'My new name'
    end

end
