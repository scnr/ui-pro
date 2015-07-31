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
        find( :xpath, "//input[@type='submit']" ).click
    end

    it_behaves_like 'Site sidebar'

    scenario 'selects sidebar button' do
        btn = find( "#sidebar-site a[@href='#{site_roles_path(site)}']" )
        expect(btn[:class]).to include 'disabled btn btn-lg'
    end

    scenario 'can update the role' do
        fill_in 'site_role_name', with: 'My new name'

        submit

        expect(subject.reload.name).to eq 'My new name'
    end

end
