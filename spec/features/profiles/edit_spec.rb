include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile edit page
#   As a user
#   I want to edit a profile
#   So I can change its options
feature 'Profile edit page', :devise do

    subject { FactoryGirl.create :profile, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'edits profile' do
            before do
                user.profiles << subject

                login_as( user, scope: :user )
                visit edit_profile_path( subject )
            end

            scenario 'has title' do
                expect(page).to have_title 'Edit'
                expect(page).to have_title subject.name
                expect(page).to have_title 'Profiles'
            end

            scenario 'has breadcrumbs' do
                breadcrumbs = find('ul.bread')

                expect(breadcrumbs.find('li:nth-of-type(1) a').native['href']).to eq root_path

                expect(breadcrumbs.find('li:nth-of-type(2)')).to have_content 'Profiles'
                expect(breadcrumbs.find('li:nth-of-type(2) a').native['href']).to eq profiles_path

                expect(breadcrumbs.find('li:nth-of-type(3)')).to have_content subject.name
                expect(breadcrumbs.find('li:nth-of-type(3) a').native['href']).to eq profile_path( subject )

                expect(breadcrumbs.find('li:nth-of-type(4)')).to have_content 'Edit'
                expect(breadcrumbs.find('li:nth-of-type(4) a').native['href']).to eq edit_profile_path( subject )
            end

            scenario 'sees profile form' do
                expect(find('.profile-form')).to be_truthy
            end

            scenario 'can submit form using sidebar button', js: true do
                fill_in 'profile_name', with: 'My name'

                find('#sidebar button').click
                sleep 1

                expect(Profile.last.name).to eq 'My name'
            end

            scenario 'sees the associated scans' do
                subject.scans << scan
                subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

                visit edit_profile_path( subject )

                subject.scans.each do |scan|
                    expect(page).to have_content scan.name
                    expect(page).to have_content scan.site.to_s
                end
            end

            feature 'when the profile has a scan with revisions' do
                before do
                    scan.revisions << revision

                    login_as( user, scope: :user )
                    visit edit_profile_path( subject )
                end

                scenario 'user gets redirected back to the profile page' do
                    expect(current_url).to eq profile_url( subject )
                end
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit edit_profile_path( subject )
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
