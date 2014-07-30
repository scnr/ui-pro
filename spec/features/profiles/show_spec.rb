include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile page
#   As a user
#   I want to visit a site
#   So I can see the profile options
feature 'Profile page', :devise do

    subject { FactoryGirl.create :profile, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }
    let(:revision) { FactoryGirl.create :revision }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'visits own profile' do
            before do
                user.profiles << subject

                login_as( user, scope: :user )
                visit profile_path( subject )
            end

            scenario 'sees the profile options'

            scenario 'sees associated scans' do
                subject.scans << scan
                subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

                visit profile_path( subject )

                subject.scans.each do |scan|
                    expect(page).to have_content scan.name
                    expect(page).to have_content scan.site.to_s
                end
            end
        end

        feature 'visits non-owned profile' do
            before do
                user.profiles << subject
                login_as( other_user, scope: :user )
            end

            scenario 'gets redirected' do
                expect do
                    visit profile_path( subject )
                end.to raise_error ActionController::RoutingError
            end
        end
    end

    feature 'non authenticated user' do
        before do
            visit profile_path( subject )
        end

        scenario 'gets redirected' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
