include Warden::Test::Helpers
Warden.test_mode!

feature 'User agent index page' do

    let(:user) { FactoryGirl.create :user }
    let(:admin) { FactoryGirl.create :user, :admin, email: 'ff@ff.cc' }
    let(:device) { FactoryGirl.create :device }
    let(:other_device) { FactoryGirl.create :device, name: 'Stuff' }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site }

    after(:each) do
        Warden.test_reset!
    end

    before do
        Device.delete_all
        device
    end

    feature 'authenticated user' do
        before do
            login_as( user, scope: :user )
            visit devices_path
        end

        scenario 'has title' do
            expect(page).to have_title 'Devices'
        end

        scenario 'can set a default user agent', js: true do
            device
            other_device

            visit devices_path

            expect(device).to_not be_default

            choose "id_#{device.id}"
            sleep(2)

            expect(device.reload).to be_default
            expect(find( "#id_#{device.id}" )).to be_checked
            expect(find( "#id_#{other_device.id}" )).to_not be_checked
        end

        feature 'can export user agent as' do
            scenario 'JSON' do
                find_button('device-export-button').click
                click_link 'JSON'

                expect(page.body).to eq device.export( JSON )
            end

            scenario 'YAML' do
                find_button('device-export-button').click
                click_link 'YAML'

                expect(page.body).to eq device.export( YAML )
            end

            scenario 'AFR' do
                find_button('device-export-button').click
                click_link 'AFP (Suitable for the CLI interface.)'

                expect(page.body).to eq device.to_rpc_options.to_yaml
            end
        end

        feature 'can import user agent as' do
            let(:file) do
                file = Tempfile.new( described_class.to_s )

                serialized = (serializer == :afr ? device.to_rpc_options.to_yaml :
                    device.export( serializer ))

                file.write serialized

                file.rewind

                allow(file).to receive(:original_filename) do
                    File.basename( file.path )
                end

                file
            end

            feature 'JSON' do
                let(:serializer) { JSON }

                scenario 'fills in the form' do
                    find(:xpath, "//a[@href='#device-import']").click
                    find('#device_file').set file.path
                    click_button 'Import'

                    expect(find('input#device_name').value).to eq device.name
                end
            end

            feature 'YAML' do
                let(:serializer) { YAML }

                scenario 'fills in the form' do
                    find(:xpath, "//a[@href='#device-import']").click
                    find('#device_file').set file.path
                    click_button 'Import'

                    expect(find('input#device_name').value).to eq device.name
                end
            end

            feature 'AFR' do
                let(:serializer) { :afr }

                scenario 'fills in the form' do
                    find(:xpath, "//a[@href='#device-import']").click
                    find('#device_file').set file.path
                    click_button 'Import'

                    expect(find('input#device_name').value).to eq File.basename( file.path )
                end
            end
        end

        scenario 'sees a list of their user agents' do
            expect(page).to have_content device.name
            expect(page).to_not have_content other_device.name
        end

        scenario 'sees the amount of scans associated with each user agent' do
            device.scans << scan

            login_as( user, scope: :user )
            visit devices_path

            expect(page).to have_content device.scans.size
        end

        scenario 'sees a new user agent link' do
            expect(page).to have_xpath "//a[@href='#{new_device_path}']"
        end

        feature 'and the user agent has no scans' do

            scenario 'can edit' do
                expect(page).to have_xpath "//a[@href='#{edit_device_path( device )}']"
            end

            scenario 'can copy' do
                expect(page).to have_xpath "//a[@href='#{copy_device_path( device )}']"
            end

            scenario 'can delete' do
                expect(page).to have_xpath "//a[@href='#{device_path( device )}' and @data-method='delete']"
            end
        end

        feature 'and the device has scans' do
            before do
                device.scans << scan

                login_as( user, scope: :user )
                visit devices_path
            end

            scenario 'cannot edit' do
                expect(find(:xpath, "//a[@href='#{edit_device_path( device )}']")[:class]).to include 'disabled'
            end

            scenario 'can copy' do
                expect(page).to have_xpath "//a[@href='#{copy_device_path( device )}']"
            end

            scenario 'cannot delete' do
                expect(find(:xpath, "//a[@href='#{device_path( device )}' and @data-method='delete']")[:class]).to include 'disabled'
            end

            feature 'when a device is default' do
                before do
                    device.default!
                    device.scans << scan
                    visit devices_path
                end

                scenario 'cannot delete' do
                    expect(find(:xpath, "//a[@href='#{device_path( device )}' and @data-method='delete']")[:class]).to include 'disabled'
                end
            end
        end
    end

    feature 'non authenticated user' do
        scenario 'gets redirected to the sign-in page' do
            user
            visit devices_path
            expect(current_url).to eq new_user_session_url
        end
    end
end
