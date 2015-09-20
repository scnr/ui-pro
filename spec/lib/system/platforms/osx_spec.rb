describe System::Platforms::OSX do
    subject { described_class.new }

    describe '#memory_free' do
        it 'returns the amount of free memory' do
            o = Object.new
            expect(o).to receive(:pagesize).and_return(4028)
            expect(o).to receive(:free).and_return(1000)
            expect(subject).to receive(:memory).and_return(o)

            expect(subject.memory_free).to eq 4_028_000
        end
    end

    describe '#cpu_count' do
        it 'returns the amount of CPUs' do
            expect(Vmstat).to receive(:cpu).and_return([1,2,3])
            expect(subject.cpu_count).to eq 3
        end
    end

    describe '#memory_for_process_group' do
        let(:ps) do
            <<EOTXT
   RSS
109744
 63732
 62236
 63876
 62772
 62856
 64504
EOTXT
        end

        it 'returns bytes of memory used by the group' do
            expect(subject).to receive(:_exec).with('ps -g 123').and_return(ps)
            expect(subject.memory_for_process_group( 123 )).to eq 2005893120
        end
    end

    describe '#kill_group' do
        it 'kills a process group'
    end

    describe '.current?' do
        context 'when running on OSX' do
            it 'returns true' do
                expect(described_class).to receive(:ruby_platform).and_return( 'universal.x86_64-darwin13' )
                expect(described_class).to be_current
            end
        end

        context 'when not running on OSX' do
            it 'returns false' do
                expect(described_class).to receive(:ruby_platform).and_return( 'x86_64-stuff' )
                expect(described_class).to_not be_current
            end
        end
    end
end
