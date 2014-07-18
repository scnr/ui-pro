describe User, type: :model do
    subject { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }

    it { should respond_to(:email) }
    it { should have_many :profiles }
    it { should have_many :sites }
    it { should have_and_belong_to_many :shared_sites }

    describe '#name' do
        it 'returns a string' do
            name = 'John Doe'
            expect(User.new( name: name ).name).to match name
        end
    end

    describe '#email' do
        it 'returns a string' do
            email = 'john@doe.com'
            expect(User.new( email: email ).email).to match email
        end
    end

    describe '#has_shared_site?' do
        context 'when the site has been shared with the user' do
            before { subject.shared_sites << site }

            it 'returns true' do
                expect(subject.has_shared_site?( site )).to be_truthy
            end
        end

        context 'when the site has not been shared with the user' do
            it 'returns false' do
                expect(subject.has_shared_site?( site )).to be_falsey
            end
        end
    end

end
