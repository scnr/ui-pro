describe Site, type: :model do
    subject { @site = FactoryGirl.create(:site) }
    let(:scan) { FactoryGirl.create :scan, site: subject }
    let(:other_scan) { FactoryGirl.create :scan, site: subject }
    let(:user) { FactoryGirl.create :user }

    expect_it { to have_one :profile_override }
    expect_it { to have_one :verification }
    expect_it { to belong_to :user }
    expect_it { to have_and_belong_to_many :users }
    expect_it { to have_many :scans }
    expect_it { to have_many :revisions }
    expect_it { to have_many :issues }
    expect_it { to have_many(:sitemap_entries).dependent(:destroy) }

    it 'has a default #verification' do
        expect(subject.verification).to be_kind_of SiteVerification
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
                    subject.protocol = 'gg'
                    subject.save
                    expect(subject.errors).to include :protocol
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

    describe :scopes do
        before { subject }

        describe :verified do
            it 'returns verified sites' do
                expect(described_class.verified).to be_empty

                subject.verification.verified!
                expect(described_class.verified).to be_any
            end
        end

        describe :unverified do
            it 'returns unverified sites' do
                expect(described_class.unverified).to be_any

                subject.verification.verified!
                expect(described_class.unverified).to be_empty
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

    describe '#verified?' do
        context 'when the site has been verified' do
            before { subject.verification.verified! }

            it 'returns true' do
                expect(subject).to be_verified
            end
        end

        context 'when the site has not been verified' do
            it 'returns false' do
                expect(subject).to_not be_verified
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

    describe '#scanned_at' do
        it 'returns the latest stop_time' do
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

            expect(subject.scanned_at.to_s).to eq latest.stopped_at.to_s
        end

        context 'when no scans have been performed' do
            it 'returns nil' do
                expect(subject.scanned_at).to be_nil
            end
        end
    end

    describe '#to_s' do
        it 'is aliased to #url' do
            expect(subject.to_s).to eq subject.url
        end
    end
end
