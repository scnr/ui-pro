describe User, type: :model do
    subject { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site }

    expect_it { to have_one  :profile_override }

    it { should respond_to(:email) }
    it { should have_many :profiles }
    it { should have_many(:sites).dependent(:destroy) }
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
end
