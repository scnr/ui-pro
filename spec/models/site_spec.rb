describe Site, type: :model do
    subject { @site = FactoryGirl.create(:site) }
    let(:scan) { FactoryGirl.create :scan, site: subject }
    let(:other_scan) { FactoryGirl.create :scan, site: subject }
    let(:user) { FactoryGirl.create :user }

    expect_it { to belong_to :user }
    expect_it { to have_one  :profile }
    expect_it { to have_and_belong_to_many :users }
    expect_it { to have_many :scans }
    expect_it { to have_many :revisions }
    expect_it { to have_many :issues }
    expect_it { to have_many(:sitemap_entries).dependent(:destroy) }

    it 'has a Guest role' do
        roles = described_class.create(
            protocol: 'http',
            host:     "test#{rand(99999)}.com",
            port:     1,
            profile:  FactoryGirl.create( :site_profile )
        ).roles

        expect(roles.size).to eq 1
        expect(roles.first).to be_guest
    end

    describe :validations do
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
            context 'is not a valid hostname' do
                it 'is not accepted' do
                    ['stuff ff.com', 'blah.c', 'g!@.com'].each do |host|
                        subject.host = host
                        subject.save
                        expect(subject.errors).to include :host

                        @site = nil
                    end
                end
            end

            context 'missing a TLD' do
                it 'is not accepted' do
                    subject.host = 'test'
                    subject.save
                    expect(subject.errors).to include :host
                end
            end

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

        it 'as URL with Arachni::URI'
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
                scan.revisions << revision
                scan.revisions << FactoryGirl.create(
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
                expect(subject.revision_in_progress).to eq revision
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
        context 'when the site has at least one stopped revision' do
            before do
                scan.revisions.create(
                    started_at: Time.now - 9000,
                    stopped_at: Time.now
                )
            end

            it 'returns true' do
                expect(subject).to be_scanned
            end
        end

        context 'when the site does not have stopped revisions' do
            before do
                scan.revisions.create(
                    started_at: Time.now - 9000
                )
            end

            it 'returns false' do
                expect(subject).to_not be_scanned
            end
        end

        context 'when the site has no revisions' do
            before do
                scan.revisions = []
                scan.save
            end

            it 'returns false' do
                expect(subject).to_not be_scanned
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

    describe '#to_s' do
        it 'is aliased to #url' do
            expect(subject.to_s).to eq subject.url
        end
    end
end
