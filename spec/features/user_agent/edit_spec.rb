include Warden::Test::Helpers
Warden.test_mode!

feature 'User-agent edit page', :devise do

    subject { FactoryGirl.create :user_agent, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:site) { FactoryGirl.create :site }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'edits user-agent' do
            before do
                login_as( user, scope: :user )
                visit edit_user_agent_path( subject )
            end

            scenario 'sees user-agent form' do
                expect(find('form')).to be_truthy
            end

            scenario 'sees the associated scans' do
                subject.scans << scan
                subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

                visit edit_user_agent_path( subject )

                subject.scans.each do |scan|
                    expect(page).to have_content scan.name
                    expect(page).to have_content scan.site.to_s
                end
            end

            feature 'when the user-agent has a scan with revisions' do
                before do
                    scan.revisions << revision

                    login_as( user, scope: :user )
                    visit edit_user_agent_path( subject )
                end

                scenario 'user gets redirected back to the user-agent page' do
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
