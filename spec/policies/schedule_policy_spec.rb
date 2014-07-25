describe SchedulePolicy do
    subject { described_class }

    let(:user) { FactoryGirl.build_stubbed :user }
    let(:admin) { FactoryGirl.build_stubbed :user, :admin }
    let(:site) { FactoryGirl.create :site, scans: [scan] }
    let(:scan) { FactoryGirl.create :scan, schedule: FactoryGirl.create( :schedule ) }
    let(:schedule) { FactoryGirl.create( :schedule, scan: scan ) }

    %w(index show).each do |action|
        permissions "#{action}?" do
            context 'when the site is' do
                context 'unverified' do
                    before { site.verification.failed! }

                    context 'when the user' do
                        context 'is the site owner' do
                            before { user.sites << site }
                            expect_it { to_not permit( user, schedule ) }
                        end

                        context 'has the shared site' do
                            before { user.shared_sites << site }
                            expect_it { to_not permit( user, schedule ) }
                        end

                        context 'is an admin' do
                            before { schedule }
                            expect_it { to permit( admin, schedule ) }
                        end

                        context 'is not associated with the site' do
                            before { site }
                            expect_it { to_not permit( user, schedule ) }
                        end

                        context 'not logged in' do
                            expect_it { to_not permit }
                        end
                    end
                end

                context 'verified' do
                    before { site.verification.verified! }

                    context 'when the user' do
                        context 'is the site owner' do
                            before { user.sites << site }
                            expect_it { to permit( user, schedule ) }
                        end

                        context 'has the shared site' do
                            before { user.shared_sites << site }
                            expect_it { to permit( user, schedule ) }
                        end

                        context 'is an admin' do
                            before { site }
                            expect_it { to permit( admin, schedule ) }
                        end

                        context 'is not associated with the site' do
                            before { site }
                            expect_it { to_not permit( user, schedule ) }
                        end

                        context 'not logged in' do
                            expect_it { to_not permit }
                        end
                    end
                end
            end
        end
    end

    %w(create update destroy).each do |action|
        permissions "#{action}?" do
            context 'when the site is' do
                context 'verified' do
                    before { site.verification.verified! }

                    context 'when the user' do
                        context 'is the site owner' do
                            before { user.sites << site }
                            expect_it { to permit( user, schedule ) }
                        end

                        context 'has the shared site' do
                            before { user.shared_sites << site }
                            expect_it { to_not permit( user, schedule ) }
                        end

                        context 'is an admin' do
                            before { site }
                            expect_it { to permit( admin, schedule ) }
                        end

                        context 'is not associated with the site' do
                            before { site }
                            expect_it { to_not permit( user, schedule ) }
                        end

                        context 'not logged in' do
                            expect_it { to_not permit }
                        end
                    end
                end

                context 'unverified' do
                    before { site.verification.failed! }

                    context 'when the user' do
                        context 'is the site owner' do
                            before { user.sites << site }
                            expect_it { to_not permit( user, schedule ) }
                        end

                        context 'has the shared site' do
                            before { user.shared_sites << site }
                            expect_it { to_not permit( user, schedule ) }
                        end

                        context 'is an admin' do
                            before { site }
                            expect_it { to permit( admin, schedule ) }
                        end

                        context 'is not associated with the site' do
                            before { site }
                            expect_it { to_not permit( user, schedule ) }
                        end

                        context 'not logged in' do
                            expect_it { to_not permit }
                        end
                    end
                end
            end
        end
    end

end
