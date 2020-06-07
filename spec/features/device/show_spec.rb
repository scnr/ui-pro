include Warden::Test::Helpers
Warden.test_mode!

feature 'Device page', :devise do

    subject { FactoryGirl.create :device, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }
    let(:revision) { FactoryGirl.create :revision }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'visits own user agent' do
            before do
                subject

                login_as( user, scope: :user )
                visit device_path( subject )
            end

            scenario 'has title' do
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
            end

            feature 'can export user agent as' do
                scenario 'JSON' do
                    find_button('device-export-button').click
                    click_link 'JSON'

                    expect(page.body).to eq subject.export( JSON )
                end

                scenario 'YAML' do
                    find_button('device-export-button').click
                    click_link 'YAML'

                    expect(page.body).to eq subject.export( YAML )
                end

                scenario 'AFR' do
                    find_button('device-export-button').click
                    click_link 'AFP (Suitable for the CLI interface.)'

                    expect(page.body).to eq subject.to_rpc_options.to_yaml
                end
            end

            feature 'and the user agent has no scans' do
                before do
                    subject.scans = []
                    subject.save

                    visit device_path( subject )
                end

                scenario 'can edit' do
                    expect(page).to have_xpath "//a[@href='#{edit_device_path( subject )}']"
                end

                scenario 'can copy' do
                    expect(page).to have_xpath "//a[@href='#{copy_device_path( subject )}']"
                end

                scenario 'can delete' do
                    expect(page).to have_xpath "//a[@href='#{device_path( subject )}' and @data-method='delete']"
                end
            end

            feature 'and the user agent has scans' do
                before do
                    subject.scans << scan

                    visit device_path( subject )
                end

                scenario 'cannot edit' do
                    expect(find(:xpath, "//a[@href='#{edit_device_path( subject )}']")[:class]).to include 'disabled'
                end

                scenario 'can copy' do
                    expect(page).to have_xpath "//a[@href='#{copy_device_path( subject )}']"
                end

                scenario 'cannot delete' do
                    expect(find(:xpath, "//a[@href='#{device_path( subject )}' and @data-method='delete']")[:class]).to include 'disabled'
                end
            end

            feature 'when a user agent is default' do
                before do
                    subject.default!
                    subject.scans << scan
                    visit device_path( subject )
                end

                scenario 'cannot delete' do
                    expect(find(:xpath, "//a[@href='#{device_path( subject )}' and @data-method='delete']")[:class]).to include 'disabled'
                end
            end

            scenario 'sees the name in the heading' do
                expect(find('h1')).to have_content subject.name
            end

            scenario 'sees the UA string' do
                expect(find('.lead')).to have_content subject.device_user_agent
            end

            scenario 'sees the resolution' do
                expect(find('.lead')).to have_content "#{subject.device_width}x#{subject.device_height}"
            end

            scenario 'sees associated scans' do
                subject.scans << scan
                subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

                visit device_path( subject )

                subject.scans.each do |scan|
                    expect(page).to have_content scan.name
                    expect(page).to have_content scan.site.to_s
                end
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit device_path( subject )
        end

        scenario 'gets redirected' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
