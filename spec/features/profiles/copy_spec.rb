include Warden::Test::Helpers
Warden.test_mode!

# Feature: Profile copy page
#   As a user
#   I want to copy a profile
feature 'Profile copy page', :devise do

    subject { FactoryGirl.create :profile, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    def submit
        find( '#sidebar button' ).click
        sleep 1
    end

    feature 'authenticated user' do
        feature 'visits copy page' do
            before do
                user.profiles << subject

                login_as( user, scope: :user )
                visit copy_profile_path( subject )
            end

            scenario 'has title' do
                expect(page).to have_title 'Copy'
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

                expect(breadcrumbs.find('li:nth-of-type(4)')).to have_content 'Copy'
                expect(breadcrumbs.find('li:nth-of-type(4) a').native['href']).to eq copy_profile_path( subject )
            end

            scenario 'sees the profile form pre-filled' do
                expect(find(:input, '#profile_name').value).to eq subject.name
            end

            scenario 'creates a new profile', js: true do
                name = 'New name here'

                fill_in 'profile_name', with: name
                submit

                expect(Profile.all.last.name).to eq name
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
