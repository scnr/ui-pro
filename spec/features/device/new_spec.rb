include Warden::Test::Helpers
Warden.test_mode!

feature 'Device new page' do

    subject { FactoryGirl.create :device, user: user }
    let(:user) { FactoryGirl.create :user }

    after(:each) do
        Warden.test_reset!
    end

    def submit
        find( '#sidebar button' ).click
        sleep 1
    end

    feature 'authenticated user' do
        before do
            login_as( user, scope: :user )
            visit new_device_path
        end

        scenario 'has title' do
            expect(page).to have_title 'New'
            expect(page).to have_title 'Devices'
        end

        scenario 'has breadcrumbs' do
            breadcrumbs = find('ul.bread')

            expect(breadcrumbs.find('li:nth-of-type(1) a').native['href']).to eq root_path

            expect(breadcrumbs.find('li:nth-of-type(2)')).to have_content 'Devices'
            expect(breadcrumbs.find('li:nth-of-type(2) a').native['href']).to eq devices_path

            expect(breadcrumbs.find('li:nth-of-type(3)')).to have_content 'New'
            expect(breadcrumbs.find('li:nth-of-type(3) a').native['href']).to eq new_device_path
        end

        scenario 'sees device form' do
            expect(find('form')).to be_truthy
        end

        feature 'form', js: true do
            before do
                fill_in 'device_name', with: 'My name'
                fill_in 'device_device_user_agent', with: 'My UA'
                fill_in 'device_device_width', with: 10
                fill_in 'device_device_height', with: 20
                check   'device_device_touch'
            end

            scenario 'can create new user-agent' do
                submit

                device = Device.last

                expect(device.name).to eq 'My name'
                expect(device.device_user_agent).to eq 'My UA'
                expect(device.device_width).to eq 10
                expect(device.device_height).to eq 20
                expect(device.device_touch).to be_truthy
            end

            feature 'Name' do
                scenario 'is mandatory' do
                    fill_in 'device_name', with: ''

                    submit

                    expect(find('.device_name.has-error').text).to include "can't be blank"
                end
            end

            feature 'User-agent' do
                scenario 'is mandatory' do
                    fill_in 'device_device_user_agent', with: ''

                    submit

                    expect(find('.device_device_user_agent.has-error').text).to include "can't be blank"
                end
            end

            feature 'Screen width' do
                scenario 'is mandatory' do
                    fill_in 'device_device_width', with: ''

                    submit

                    expect(find('.device_device_width.has-error').text).to include "can't be blank"
                end
            end

            feature 'Screen height' do
                scenario 'is mandatory' do
                    fill_in 'device_device_height', with: ''

                    submit

                    expect(find('.device_device_height.has-error').text).to include "can't be blank"
                end
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit new_device_path
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
