describe User, type: :model do
    before(:each) { @user = User.new( email: 'user@example.com' ) }

    subject { @user }

    it { should respond_to(:email) }
    it { should have_and_belong_to_many :sites }

    it '#email returns a string' do
        expect(subject.email).to match 'user@example.com'
    end

end
