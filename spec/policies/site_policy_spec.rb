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
            context 'when the site is' do
                context 'unverified' do
                    before { site.verification.failed! }

                    context 'when the user' do
                        context 'is the site owner' do
                            before { user.sites << site }
                            expect_it { to_not permit( user, site ) }
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

                context 'verified' do
                    before { site.verification.verified! }

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
        end
    end

    %w(edit invite_user).each do |action|
        permissions "#{action}?" do
            context 'when the user' do
                context 'when the site is' do
                    context 'unverified' do
                        before { site.verification.failed! }

                        context 'is the site owner' do
                            before { user.sites << site }
                            expect_it { to_not permit( user, site ) }
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

                    context 'verified' do
                        before { site.verification.verified! }

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
    end

    %w(destroy verify verification).each do |action|
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

    describe '#permitted_attributes' do
        let(:permitted_attributes) { subject.new(user, site).permitted_attributes }

        [:protocol, :host, :port].each do |attribute|
            it "includes #{attribute}" do
                expect(permitted_attributes).to include attribute
            end
        end

        context 'when the user is an admin' do
            let(:user) { admin }

            it 'includes profile_override' do
                expect(permitted_attributes).to include :profile_override
            end
        end
    end

end
