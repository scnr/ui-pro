describe Site, type: :model do
    subject { @site = FactoryGirl.create(:site, user: user) }
    let(:scan) { FactoryGirl.create :scan, site: subject }
    let(:other_scan) { FactoryGirl.create :scan, site: subject }
    let(:user) { FactoryGirl.create :user }
    let(:settings) { Settings }

    expect_it { to belong_to :user }
    expect_it { to have_one  :profile }
    expect_it { to have_and_belong_to_many :users }
    expect_it { to have_many(:scans).dependent(:destroy) }
    expect_it { to have_many(:revisions).dependent(:destroy) }
    expect_it { to have_many(:issues).dependent(:destroy) }
    expect_it { to have_many :schedules }
    expect_it { to have_many(:roles).dependent(:destroy) }
    expect_it { to have_many(:sitemap_entries).dependent(:destroy) }

    it 'has a Guest role' do
        roles = subject.roles
        expect(roles.size).to eq 1
        expect(roles.first).to be_guest
    end

    it 'has a profile with default options' do
        profile = described_class.create(
            protocol: 'http',
            host:     "test#{rand(99999)}.com",
            port:     1
        ).profile

        SiteProfile.flatten( Arachni::Options.to_rpc_data ).each do |k, v|
            expect(profile.send(k)).to eq v
        end
    end

    describe :validations do
        describe '#max_parallel_scans' do
            context 'when there is a global setting' do
                context 'when its value is greater than the global setting' do
                    before do
                        settings.max_parallel_scans = 2
                        settings.save
                    end

                    it 'is invalid' do
                        subject.max_parallel_scans = 3

                        expect(subject).to be_invalid
                        expect(subject.errors).to include :max_parallel_scans
                    end
                end

                context 'when the value is 0' do
                    it 'is invalid' do
                        subject.max_parallel_scans = 0

                        expect(subject).to be_invalid
                        expect(subject.errors).to include :max_parallel_scans
                    end
                end

                context 'when the value is less than 0' do
                    it 'is invalid' do
                        subject.max_parallel_scans = -1

                        expect(subject).to be_invalid
                        expect(subject.errors).to include :max_parallel_scans
                    end
                end
            end

            context 'when there is no global setting' do
                before do
                    settings.max_parallel_scans = nil
                    settings.save
                end

                it 'is valid' do
                    subject.max_parallel_scans = 3000000

                    expect(subject).to be_valid
                end
            end
        end

        describe '#protocol' do
            context :http do
                it 'is accepted' do
                    subject.protocol = 'http'
                    subject.save
                    expect(subject.errors).to be_empty
                end
            end

            context :https do
                it 'is accepted' do
                    subject.protocol = 'https'
                    subject.save
                    expect(subject.errors).to be_empty
                end
            end

            context 'other' do
                it 'is not accepted' do
                    expect { subject.protocol = 'gg' }.to raise_error
                end
            end

            context 'nil' do
                it 'is not accepted' do
                    subject.protocol = nil
                    subject.save
                    expect(subject.errors).to include :protocol
                end
            end
        end

        describe '#host' do
            context 'nil' do
                it 'is not accepted' do
                    subject.host = nil
                    subject.save
                    expect(subject.errors).to include :host
                end
            end

            it 'is unique for #port, #protocol and #user' do
                site = Site.new(
                    protocol: 'https',
                    host:     'test.com',
                    port:     22,
                    user:     user
                )
                expect(site.save).to be_truthy

                site = Site.new(
                    protocol: 'https',
                    host:     'test.com',
                    port:     22,
                    user:     user
                )
                expect(site.save).to be_falsey

                site = Site.new(
                    protocol: 'http',
                    host:     'test.com',
                    port:     22,
                    user:     user
                )
                expect(site.save).to be_truthy

                site = Site.new(
                    protocol: 'https',
                    host:     'test.com',
                    port:     21,
                    user:     user
                )
                expect(site.save).to be_truthy

                site = Site.new(
                    protocol: 'https',
                    host:     'test2.com',
                    port:     22,
                    user:     user
                )
                expect(site.save).to be_truthy

                site = Site.new(
                    protocol: 'https',
                    host:     'test2.com',
                    port:     22,
                    user:     FactoryGirl.create(:user, email: 'gg@ff.ff' )
                )
                expect(site.save).to be_truthy
            end
        end

        describe '#port' do
            context 'is numeric' do
                context 'as a Numeric' do
                    it 'is accepted' do
                        subject.port = 12
                        subject.save
                        expect(subject.errors).to be_empty
                    end
                end

                context 'as a String' do
                    it 'is accepted' do
                        subject.port = '12'
                        subject.save
                        expect(subject.errors).to be_empty
                    end
                end

                context '0' do
                    it 'is not accepted' do
                        subject.port = 0
                        subject.save
                        expect(subject.errors).to include :port
                    end
                end

                context '< 0' do
                    it 'is not accepted' do
                        subject.port = -1
                        subject.save
                        expect(subject.errors).to include :port
                    end
                end
            end

            context 'non numeric' do
                it 'is not accepted' do
                    subject.port = 'test'
                    subject.save
                    expect(subject.errors).to include :port
                end
            end

            context 'nil' do
                it 'is not accepted' do
                    subject.port = nil
                    subject.save
                    expect(subject.errors).to include :port
                end
            end
        end
    end

    describe '#url' do
        context 'when protocol is' do
            context 'http' do
                context 'and port is' do
                    context 80 do
                        it 'it does not include the port number' do
                            site = Site.new(
                                protocol: 'http',
                                host:      'text.com',
                                port:      80
                            )

                            expect(site.url).to eq 'http://text.com'
                        end
                    end

                    context 'other' do
                        it 'it includes the port number' do
                            site = Site.new(
                                protocol: 'http',
                                host:      'text.com',
                                port:      81
                            )

                            expect(site.url).to eq 'http://text.com:81'
                        end
                    end
                end
            end

            context 'https' do
                context 'and port is' do
                    context 443 do
                        it 'it does not include the port number' do
                            site = Site.new(
                                protocol: 'https',
                                host:      'text.com',
                                port:      443
                            )

                            expect(site.url).to eq 'https://text.com'
                        end
                    end

                    context 'other' do
                        it 'it includes the port number' do
                            site = Site.new(
                                protocol: 'https',
                                host:      'text.com',
                                port:      444
                            )

                            expect(site.url).to eq 'https://text.com:444'
                        end
                    end
                end
            end
        end
    end

    describe '#destroy' do
        it 'destroys associated scans' do
            subject.scans << scan
            subject.scans << other_scan

            subject.destroy

            expect{ scan.reload }.to raise_error ActiveRecord::RecordNotFound
            expect{ other_scan.reload }.to raise_error ActiveRecord::RecordNotFound
        end
    end

    describe '#scanned_or_being_scanned?' do
        context 'when the site has a revision that has started but not stopped' do
            before do
                scan.revisions.create(
                    started_at: Time.now - 9000
                )
            end

            it 'returns true' do
                expect(subject).to be_scanned_or_being_scanned
            end
        end

        context 'when the site has a stopped revision' do
            before do
                scan.revisions.create(
                    started_at: Time.now - 9000,
                    stopped_at: Time.now
                )
            end

            it 'returns true' do
                expect(subject).to be_scanned_or_being_scanned
            end
        end

        context 'when the site has neither started nor stopped revisions' do
            before do
                scan.revisions.create
            end

            it 'returns false' do
                expect(subject).to_not be_scanned_or_being_scanned
            end
        end

        context 'when the site has no revisions' do
            before do
                scan.revisions = []
                scan.save
            end

            it 'returns false' do
                expect(subject).to_not be_scanned_or_being_scanned
            end
        end
    end

    describe '#being_scanned?' do
        context 'when the site has a revision that has started but not stopped' do
            before do
                scan.revisions.create(
                    started_at: Time.now - 9000
                )
            end

            it 'returns true' do
                expect(subject.being_scanned?).to be_truthy
            end
        end

        context 'when the site has a stopped revision' do
            before do
                scan.revisions.create(
                    started_at: Time.now - 9000,
                    stopped_at: Time.now
                )
            end

            it 'returns false' do
                expect(subject.being_scanned?).to be_falsey
            end
        end

        context 'when the site has neither started nor stopped revisions' do
            before do
                scan.revisions.create
            end

            it 'returns false' do
                expect(subject.being_scanned?).to be_falsey
            end
        end

        context 'when the site has no revisions' do
            before do
                scan.revisions = []
                scan.save
            end

            it 'returns false' do
                expect(subject.being_scanned?).to be_falsey
            end
        end
    end

    describe '#revision_in_progress' do
        context 'when the site has a revisions that has started but not stopped' do
            before do
                revision
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    stopped_at: nil
                )
            end
            let(:revision) do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    stopped_at: nil
                )
            end

            it 'returns the first one' do
                expect(subject.reload.revision_in_progress).to eq revision
            end
        end

        context 'when the site has a stopped revision' do
            before do
                scan.revisions.create(
                    started_at: Time.now - 9000,
                    stopped_at: Time.now
                )
            end

            it 'returns nil' do
                expect(subject.revision_in_progress).to be_nil
            end
        end

        context 'when the site has neither started nor stopped revisions' do
            before do
                scan.revisions.create
            end

            it 'returns false' do
                expect(subject.revision_in_progress).to be_nil
            end
        end

        context 'when the site has no revisions' do
            before do
                scan.revisions = []
                scan.save
            end

            it 'returns false' do
                expect(subject.revision_in_progress).to be_nil
            end
        end
    end

    describe '#scanned?' do
        context 'when the site has revisions' do
            before do
                scan.revisions.create(
                    started_at: Time.now - 9000,
                    stopped_at: Time.now
                )
            end

            it 'returns true' do
                expect(subject.reload).to be_scanned
            end
        end

        context 'when the site has no revisions' do
            before do
                scan.revisions = []
                scan.save
            end

            it 'returns false' do
                expect(subject.reload).to_not be_scanned
            end
        end
    end

    describe '#last_scanned_at' do
        it 'returns the latest stop time' do
            scan.revisions.create(
                stopped_at: Time.now - 9000
            )
            latest = scan.revisions.create(
                stopped_at: Time.now - 5000
            )
            scan.revisions.create(
                stopped_at: Time.now - 10000
            )

            scan.revisions.create

            expect(subject.last_scanned_at.to_s).to eq latest.stopped_at.to_s
        end

        context 'when no scans have been performed' do
            it 'returns nil' do
                expect(subject.last_scanned_at).to be_nil
            end
        end
    end

    describe '#favicon_path' do
        context 'when it has a favicon' do
            before do
                expect(subject).to receive(:has_favicon?).and_return( true )
            end

            it 'returns #provisioned_favicon_path' do
                expect(subject.favicon_path).to eq subject.provisioned_favicon_path
            end
        end

        context 'when it does not have a favicon' do
            before do
                expect(subject).to receive(:has_favicon?).and_return( false )
            end

            it 'returns nil' do
                expect(subject.favicon_path).to be_nil
            end
        end
    end

    describe '#favicon' do
        context 'when it has a favicon' do
            before do
                expect(subject).to receive(:has_favicon?).and_return( true )
            end

            it 'returns #provisioned_favicon' do
                expect(subject.favicon).to eq subject.provisioned_favicon
            end
        end

        context 'when it does not have a favicon' do
            before do
                expect(subject).to receive(:has_favicon?).and_return( false )
            end

            it 'returns nil' do
                expect(subject.favicon).to be_nil
            end
        end
    end

    describe '#has_favicon?' do
        context 'when the favicon file exists' do
            before do
                IO.write subject.provisioned_favicon_path, ''
            end

            expect_it { to have_favicon }
        end

        context 'when the favicon file does not exist' do
            before do
                FileUtils.rm_f subject.provisioned_favicon_path
            end

            expect_it { to_not have_favicon }
        end
    end

    describe '#provisioned_favicon_path' do
        it 'returns the file-system path to the icon' do
            expect(subject.provisioned_favicon_path).to eq "#{described_class::FAVICONS_DIR}/#{subject.provisioned_favicon}"
        end
    end

    describe '#provisioned_favicon' do
        it 'returns the icon name' do
            expect(subject.provisioned_favicon).to eq "#{subject.host}_#{subject.port}.ico"
        end
    end

    describe '#to_s' do
        it 'is aliased to #url' do
            expect(subject.to_s).to eq subject.url
        end
    end
end
