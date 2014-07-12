describe SitePolicy do
    subject { described_class }

    let(:user) { FactoryGirl.build_stubbed :user }
    let(:admin) { FactoryGirl.build_stubbed :user, :admin }
    let(:site) { FactoryGirl.create :site }

    %w(index new create).each do |action|
        permissions "#{action}?" do
            context 'when the user is' do
                context 'logged in' do
                    expect_it { to permit(user) }
                end

                context 'not logged in' do
                    expect_it { to_not permit }
                end
            end
        end
    end

    %w(show).each do |action|
        permissions "#{action}?" do
            context 'when the user' do
                context 'is the site owner' do
                    before { user.sites << site }
                    expect_it { to permit( user, site ) }
                end

                context 'has the shared site' do
                    before { user.shared_sites << site }
                    expect_it { to permit( user, site ) }
                end

                context 'is an admin' do
                    before { site }
                    expect_it { to permit( admin, site ) }
                end

                context 'is not associated with the site' do
                    before { site }
                    expect_it { to_not permit( user, site ) }
                end

                context 'not logged in' do
                    expect_it { to_not permit }
                end
            end
        end
    end

    %w(edit update destroy).each do |action|
        permissions "#{action}?" do
            context 'when the user' do
                context 'is the site owner' do
                    before { user.sites << site }
                    expect_it { to permit( user, site ) }
                end

                context 'has the shared site' do
                    before { user.shared_sites << site }
                    expect_it { to_not permit( user, site ) }
                end

                context 'is an admin' do
                    before { site }
                    expect_it { to permit( admin, site ) }
                end

                context 'is not associated with the site' do
                    before { site }
                    expect_it { to_not permit( user, site ) }
                end

                context 'not logged in' do
                    expect_it { to_not permit }
                end
            end
        end
    end

end
