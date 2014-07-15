describe ApplicationPolicy do
    subject { described_class }

    let (:current_user) { FactoryGirl.build_stubbed :user }
    let (:other_user) { FactoryGirl.build_stubbed :user }
    let (:admin) { FactoryGirl.build_stubbed :user, :admin }
end
