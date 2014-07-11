describe Site, type: :model do
    subject { @site = FactoryGirl.create(:site) }

    expect_it { to have_one :verification }
    expect_it { to have_and_belong_to_many :users }

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

    describe '#to_s' do
        it 'is aliased to #url' do
            expect(subject.to_s).to eq subject.url
        end
    end
end
