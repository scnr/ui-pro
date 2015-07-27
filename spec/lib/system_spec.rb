describe System do
    subject { described_class.instance }

    before do
        subject.reset
    end

    describe '#memory_free' do
        it 'delegates to #platform' do
            expect(subject.platform).to receive(:memory_free).and_return(10)
            expect(subject.memory_free).to eq 10
        end
    end

    describe '#cpu_count' do
        it 'delegates to #platform' do
            expect(subject.platform).to receive(:cpu_count).and_return(10)
            expect(subject.cpu_count).to eq 10
        end
    end

    describe '#platform' do
        it 'returns the current platform' do
            platform_stub = Class.new do
                def self.current?
                    true
                end
            end

            subject.platforms.unshift platform_stub

            expect(subject.platform).to be_instance_of platform_stub

            subject.platforms.delete platform_stub
        end

        context 'when the platform could not be identified' do
            it 'raises error' do
                subject.platforms.each do |platform|
                    expect(platform).to receive(:current?).and_return(false)
                end

                expect do
                    subject.platform
                end.to raise_error "Unsupported platform: #{RUBY_PLATFORM}"
            end
        end
    end

    describe '#platforms' do
        it 'returns all supported platforms' do
            expect(subject.platforms.map(&:to_s).sort).to eq [
                described_class::Platforms::Linux,
                described_class::Platforms::OSX,
                described_class::Platforms::Windows
            ].map(&:to_s).sort
        end
    end
end
