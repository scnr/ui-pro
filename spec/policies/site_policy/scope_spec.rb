describe SitePolicy::Scope do
    subject { described_class.new( user, Site ).resolve.to_a }
    let(:simple_user) { FactoryGirl.build_stubbed :user }
    let(:admin) { FactoryGirl.build_stubbed :user, :admin }
    let(:site) { FactoryGirl.create :site }
    let(:other_site) { FactoryGirl.create :site, host: 'fssf.fff' }

    before do
        Site.delete_all
        site
        other_site
    end

    context 'when user is an administrator' do
        let(:user) { admin }

        expect_it { to eq [site, other_site]}
    end

    context 'when user has own sites' do
        before do
            user.sites << site
        end
        let(:user) { simple_user }

        expect_it { to eq [site] }
    end

    context 'when user has shared sites' do
        before do
            user.shared_sites << site
        end
        let(:user) { simple_user }

        expect_it { to eq [site] }
    end

    context 'when user owns and has shared sites' do
        before do
            user.sites << site
            user.shared_sites << other_site
        end
        let(:user) { simple_user }

        expect_it { to eq [site, other_site] }
    end

    context 'when user has no sites' do
        let(:user) { simple_user }

        expect_it { to be_empty }
    end
end
