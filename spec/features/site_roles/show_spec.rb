include Warden::Test::Helpers
Warden.test_mode!

feature 'Show site role page', js: true do

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
        visit site_path( site )

        click_link 'Roles'
        find( :xpath, "//a[@href='#!/roles/1']" ).click
    end

    scenario 'can be visited by URL fragment' do
        visit "#{site_path( site )}#!/roles/1"
    end

    scenario 'sees name in heading' do
        expect(find('h2')).to have_content subject.name
    end

    scenario 'sees description' do
        expect(page).to have_content subject.description
    end

    scenario 'sees associated scans' do
        subject.scans << scan
        subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

        visit "#{site_path( site )}#!/roles/1"

        subject.scans.each do |scan|
            expect(page).to have_content scan.name
            expect(page).to have_content scan.site.to_s
        end
    end

    scenario 'sees session check URL' do
        expect(page).to have_content subject.session_check_url
    end

    scenario 'sees session check pattern' do
        expect(page).to have_content subject.session_check_pattern
    end

    feature 'when login type is' do
        feature 'form' do
            before do
                subject.login_type = 'form'
                subject.save
                visit "#{site_path( site )}#!/roles/1"
            end

            scenario 'sees form URL' do
                expect(page).to have_content subject.login_form_url
            end

            scenario 'sees form parameters' do
                parameters_table = find('table')

                subject.login_form_parameters.each do |name, value|
                    expect(parameters_table).to have_content name
                    expect(parameters_table).to have_content value
                end
            end
        end

        feature 'script' do
            before do
                subject.login_type = 'script'
                subject.save
                visit "#{site_path( site )}#!/roles/1"
            end

            scenario 'sees script code' do
                expect(page).to have_css 'table.CodeRay'
            end
        end
    end
end
