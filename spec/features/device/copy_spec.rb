include Warden::Test::Helpers
Warden.test_mode!

feature 'Device copy page', :devise do

    subject { FactoryGirl.create :device, scans: [scan] }
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
                login_as( user, scope: :user )
                visit copy_device_path( subject )
            end

            scenario 'has title' do
                expect(page).to have_title 'Copy'
                expect(page).to have_title subject.name
                expect(page).to have_title 'Devices'
            end

            scenario 'has breadcrumbs' do
                breadcrumbs = find('ul.bread')

                expect(breadcrumbs.find('li:nth-of-type(1) a').native['href']).to eq root_path

                expect(breadcrumbs.find('li:nth-of-type(2)')).to have_content 'Devices'
                expect(breadcrumbs.find('li:nth-of-type(2) a').native['href']).to eq devices_path

                expect(breadcrumbs.find('li:nth-of-type(3)')).to have_content subject.name
                expect(breadcrumbs.find('li:nth-of-type(3) a').native['href']).to eq device_path( subject )

                expect(breadcrumbs.find('li:nth-of-type(4)')).to have_content 'Copy'
                expect(breadcrumbs.find('li:nth-of-type(4) a').native['href']).to eq copy_device_path( subject )
            end

            scenario 'sees the user-agent form pre-filled' do
                expect(find('#device_name').value).to eq subject.name
            end

            scenario 'creates a new user-agent', js: true do
                name = 'New name here'

                fill_in 'device_name', with: name
                submit

                expect(Device.last.name).to eq name
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit edit_device_path( subject )
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
