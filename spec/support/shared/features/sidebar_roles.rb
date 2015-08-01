shared_examples_for 'Roles sidebar' do |options = {}|
    subject { FactoryGirl.create :site_role, site: site }
    let(:other_role) { FactoryGirl.create :site_role, site: site }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:other_revision) { FactoryGirl.create :revision, scan: scan }

    let(:sidebar) { find '#sidebar #sidebar-roles' }

    def roles_sidebar_refresh
        visit current_url
    end

    before do
        subject
        other_role
        roles_sidebar_refresh
    end

    scenario 'user sees role names' do
        site.roles.each do |role|
            expect(sidebar).to have_content role.name
        end
    end

    scenario 'user sees role links' do
        site.roles.each do |role|
            expect(sidebar).to have_xpath "//a[@href='#{site_role_path( site, role )}']"
        end
    end

    feature 'when the role has scans' do
        before do
            subject.scans << scan
            subject.save

            roles_sidebar_refresh
        end

        scenario 'user sees amount of scans' do
            expect(sidebar.find("#sidebar-role-#{subject.id} .badge")).to have_content subject.scans.size
        end
    end

    feature 'when the role has no scans' do
        scenario 'user does not see a count' do
            expect(sidebar.find("#sidebar-role-#{subject.id}")).to_not have_css '.badge'
        end
    end

end
