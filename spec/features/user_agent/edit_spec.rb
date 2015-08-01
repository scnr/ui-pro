include Warden::Test::Helpers
Warden.test_mode!

feature 'User agent edit page', :devise do

    subject { FactoryGirl.create :user_agent }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'edits user agent' do
            before do
                login_as( user, scope: :user )

                visit edit_user_agent_path( subject )
            end

            scenario 'has title' do
                expect(page).to have_title 'Edit'
                expect(page).to have_title subject.name
                expect(page).to have_title 'User agents'
            end

            scenario 'has breadcrumbs' do
                breadcrumbs = find('ul.bread')

                expect(breadcrumbs.find('li:nth-of-type(1) a').native['href']).to eq root_path

                expect(breadcrumbs.find('li:nth-of-type(2)')).to have_content 'User agents'
                expect(breadcrumbs.find('li:nth-of-type(2) a').native['href']).to eq user_agents_path

                expect(breadcrumbs.find('li:nth-of-type(3)')).to have_content subject.name
                expect(breadcrumbs.find('li:nth-of-type(3) a').native['href']).to eq user_agent_path( subject )

                expect(breadcrumbs.find('li:nth-of-type(4)')).to have_content 'Edit'
                expect(breadcrumbs.find('li:nth-of-type(4) a').native['href']).to eq edit_user_agent_path( subject )
            end

            scenario 'sees user agent form' do
                expect(find('form')).to be_truthy
            end

            feature 'when the user agent has scans' do
                before do
                    subject.scans << scan

                    login_as( user, scope: :user )
                    visit edit_user_agent_path( subject )
                end

                scenario 'user gets redirected back to the user agent page' do
                    expect(current_url).to eq user_agent_url( subject )
                end
            end
        end
    end

    feature 'non authenticated user' do
        before do
            user
            visit edit_user_agent_path( subject )
        end

        scenario 'gets redirected to the login page' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
