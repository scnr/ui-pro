describe ProfilePolicy do
    subject { described_class }

    let(:user) { FactoryGirl.build_stubbed :user }
    let(:admin) { FactoryGirl.build_stubbed :user, :admin }
    let(:profile) { FactoryGirl.create :profile }
    let(:scan) { FactoryGirl.create :scan }

    %w(index new copy create).each do |action|
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
                    before { user.profiles << profile }
                    expect_it { to permit( user, profile ) }
                end

                context 'is an admin' do
                    before { profile }
                    expect_it { to permit( admin, profile ) }
                end

                context 'is not associated with the site' do
                    before { profile }
                    expect_it { to_not permit( user, profile ) }
                end

                context 'not logged in' do
                    expect_it { to_not permit }
                end
            end
        end
    end

    %w(update destroy).each do |action|
        permissions "#{action}?" do
            context 'when the profile does not have any scans' do
                context 'when the user' do
                    context 'is the site owner' do
                        before { user.profiles << profile }
                        expect_it { to permit( user, profile ) }
                    end

                    context 'is an admin' do
                        before { profile }
                        expect_it { to permit( admin, profile ) }
                    end

                    context 'is not associated with the site' do
                        before { profile }
                        expect_it { to_not permit( user, profile ) }
                    end

                    context 'not logged in' do
                        expect_it { to_not permit }
                    end
                end
            end

            context 'when the profile has scans' do
                before { profile.scans << scan }

                context 'without revisions' do

                    context 'when the user' do
                        context 'is the site owner' do
                            before { user.profiles << profile }
                            expect_it { to permit( user, profile ) }
                        end

                        context 'is an admin' do
                            before { profile }
                            expect_it { to permit( admin, profile ) }
                        end

                        context 'is not associated with the site' do
                            before { profile }
                            expect_it { to_not permit( user, profile ) }
                        end

                        context 'not logged in' do
                            expect_it { to_not permit }
                        end
                    end
                end

                context 'with revisions' do
                    before { scan.revisions << FactoryGirl.create(:revision) }

                    context 'when the user' do
                        context 'is the site owner' do
                            before { user.profiles << profile }
                            expect_it { to_not permit( user, profile ) }
                        end

                        context 'is an admin' do
                            before { profile }
                            expect_it { to permit( admin, profile ) }
                        end

                        context 'is not associated with the site' do
                            before { profile }
                            expect_it { to_not permit( user, profile ) }
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
