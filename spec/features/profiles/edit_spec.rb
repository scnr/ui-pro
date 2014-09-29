include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile edit page
#   As a user
#   I want to edit a profile
#   So I can change its options
feature 'Profile edit page', :devise do

    subject { FactoryGirl.create :profile, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'edits own profile' do
            before do
                user.profiles << subject

                login_as( user, scope: :user )
                visit edit_profile_path( subject )
            end

            scenario 'sees the profile options'

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

                scenario 'user gets redirected back to the homepage' do
                    expect(current_url).to eq root_url
                end
            end
        end

        feature 'visits non-owned profile' do
            before do
                user.profiles << subject
                login_as( other_user, scope: :user )
            end

            scenario 'gets a 404 error' do
                expect do
                    visit edit_profile_path( subject )
                end.to raise_error ActionController::RoutingError
            end
        end
    end

    feature 'non authenticated user' do
        before do
            visit edit_profile_path( subject )
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
