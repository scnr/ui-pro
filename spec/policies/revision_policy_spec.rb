describe RevisionPolicy do
    subject { described_class }

    let(:user) { FactoryGirl.build_stubbed :user }
    let(:admin) { FactoryGirl.build_stubbed :user, :admin }
    let(:guest) { FactoryGirl.build_stubbed :user, :guest }

    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site }

    %w(show).each do |action|
        permissions "#{action}?" do
            before { site.verification.verified! }

            context 'when the user' do
                context 'is the site owner' do
                    before { user.sites << site }
                    expect_it { to permit( user, revision ) }
                end

                context 'has the shared site' do
                    before { user.shared_sites << site }
                    expect_it { to permit( user, revision ) }
                end

                context 'is an admin' do
                    before { site }
                    expect_it { to permit( admin, revision ) }
                end

                context 'is not associated with the site' do
                    before { site }
                    expect_it { to_not permit( user, revision ) }
                end

                context 'not logged in' do
                    expect_it { to_not permit }
                end
            end
        end
    end

    %w(destroy).each do |action|
        permissions "#{action}?" do
            context 'when the user' do
                before { site.verification.verified! }

                context 'is the site owner' do
                    before { user.sites << site }
                    expect_it { to permit( user, revision ) }
                end

                context 'has the shared site' do
                    before { user.shared_sites << site }
                    expect_it { to_not permit( user, revision ) }
                end

                context 'is an admin' do
                    before { site }
                    expect_it { to permit( admin, revision ) }
                end

                context 'is not associated with the site' do
                    before { site }
                    expect_it { to_not permit( user, revision ) }
                end

                context 'not logged in' do
                    expect_it { to_not permit }
                end
            end
        end
    end
end
