describe ProfileOverridePolicy do
    subject { described_class }

    let(:user) { FactoryGirl.build_stubbed :user }
    let(:admin) { FactoryGirl.build_stubbed :user, :admin }
    let(:site) { FactoryGirl.create :site }

    describe '#permitted_attributes' do
        let(:permitted_attributes) { subject.new(user, site).permitted_attributes }

        context 'when the user is not an admin' do
            it 'returns empty array' do
                expect(permitted_attributes).to be_empty
            end
        end

        context 'when the user is an admin' do
            let(:user) { admin }
            let(:delegated) do
                ProfilePolicy.new( user, site ).permitted_attributes +
                    GlobalProfilePolicy.new( user, site ).permitted_attributes +
                    [:scope_page_limit]
            end

            it "delegates to #{ProfilePolicy} and #{GlobalProfilePolicy}" do
                expect(permitted_attributes).to eq delegated
            end
        end
    end

end
