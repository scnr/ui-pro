include Warden::Test::Helpers
Warden.test_mode!

feature 'User-agent page', :devise do

    subject { FactoryGirl.create :user_agent, scans: [scan] }
    let(:user) { FactoryGirl.create :user }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }
    let(:revision) { FactoryGirl.create :revision }

    after(:each) do
        Warden.test_reset!
    end

    feature 'authenticated user' do
        feature 'visits own user_agent' do
            before do
                subject

                login_as( user, scope: :user )
                visit user_agent_path( subject )
            end

            scenario 'sees the user_agent options'

            scenario 'sees associated scans' do
                subject.scans << scan
                subject.scans << FactoryGirl.create( :scan, name: 'Fff', site: site )

                visit user_agent_path( subject )

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
            visit user_agent_path( subject )
        end

        scenario 'gets redirected' do
            expect(current_url).to eq new_user_session_url
        end
    end
end
