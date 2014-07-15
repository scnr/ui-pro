describe ScanPolicy do
    subject { described_class }

    let(:user) { FactoryGirl.build_stubbed :user }
    let(:admin) { FactoryGirl.build_stubbed :user, :admin }
    let(:guest) { FactoryGirl.build_stubbed :user, :guest }

    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site }

    %w(index show new create).each do |action|
        permissions "#{action}?" do
            context 'when the site is' do
                context 'unverified' do
                    before { site.verification.failed! }

                    context 'when the user' do
                        context 'is the site owner' do
                            before { user.sites << site }
                            expect_it { to_not permit( user, scan ) }
                        end

                        context 'has the shared site' do
                            before { user.shared_sites << site }
                            expect_it { to_not permit( user, scan ) }
                        end

                        context 'is an admin' do
                            before { site }
                            expect_it { to permit( admin, site ) }
                        end

                        context 'is not associated with the site' do
                            before { site }
                            expect_it { to_not permit( user, scan ) }
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
                            expect_it { to permit( user, scan ) }
                        end

                        context 'has the shared site' do
                            before { user.shared_sites << site }
                            expect_it { to permit( user, scan ) }
                        end

                        context 'is an admin' do
                            before { site }
                            expect_it { to permit( admin, site ) }
                        end

                        context 'is not associated with the site' do
                            before { site }
                            expect_it { to_not permit( user, scan ) }
                        end

                        context 'not logged in' do
                            expect_it { to_not permit }
                        end
                    end
                end
            end
        end
    end

    %w(update edit destroy).each do |action|
        permissions "#{action}?" do
            context 'when the user' do
                context 'when the site is' do
                    context 'unverified' do
                        before { site.verification.failed! }

                        context 'is the site owner' do
                            before { user.sites << site }
                            expect_it { to_not permit( user, scan ) }
                        end

                        context 'has the shared site' do
                            before { user.shared_sites << site }
                            expect_it { to_not permit( user, scan ) }
                        end

                        context 'is an admin' do
                            before { site }
                            expect_it { to permit( admin, site ) }
                        end

                        context 'is not associated with the site' do
                            before { site }
                            expect_it { to_not permit( user, scan ) }
                        end

                        context 'not logged in' do
                            expect_it { to_not permit }
                        end
                    end

                    context 'verified' do
                        before { site.verification.verified! }

                        context 'is the site owner' do
                            before { user.sites << site }
                            expect_it { to permit( user, scan ) }
                        end

                        context 'has the shared site' do
                            before { user.shared_sites << site }
                            expect_it { to_not permit( user, scan ) }
                        end

                        context 'is an admin' do
                            before { site }
                            expect_it { to permit( admin, site ) }
                        end

                        context 'is not associated with the site' do
                            before { site }
                            expect_it { to_not permit( user, scan ) }
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
