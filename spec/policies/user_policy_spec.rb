describe UserPolicy do
    subject { UserPolicy }

    let (:current_user) { FactoryGirl.build_stubbed :user }
    let (:other_user) { FactoryGirl.build_stubbed :user }
    let (:admin) { FactoryGirl.build_stubbed :user, :admin }

    permissions :index? do
        it "denies access if not an admin" do
            expect(UserPolicy).not_to permit(current_user)
        end
        it "allows access for an admin" do
            expect(UserPolicy).to permit(admin)
        end
    end

    permissions :show? do
        it "prevents other users from seeing your profile" do
            expect(subject).not_to permit(current_user, other_user)
        end
        it "allows you to see your own profile" do
            expect(subject).to permit(current_user, current_user)
        end
        it "allows an admin to see any profile" do
            expect(subject).to permit(admin)
        end
    end

    permissions :update? do
        it "prevents updates if not an admin" do
            expect(subject).not_to permit(current_user)
        end
        it "allows an admin to make updates" do
            expect(subject).to permit(admin)
        end
    end

    permissions :destroy? do
        it "prevents deleting yourself" do
            expect(subject).not_to permit(current_user, current_user)
        end
        it "allows an admin to delete any user" do
            expect(subject).to permit(admin, other_user)
        end
    end

    describe '#permitted_attributes' do
        let(:user) { current_user }
        let(:permitted_attributes) { subject.new(user, current_user).permitted_attributes }

        it 'returns empty array' do
            expect(permitted_attributes).to be_empty
        end

        context 'when the user is an admin' do
            let(:user) { admin }

            [:role, :profile_override].each do |attribute|
                it "includes #{attribute}" do
                    expect(permitted_attributes).to include attribute
                end
            end
        end
    end

end
