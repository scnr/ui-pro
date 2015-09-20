describe System::Platforms::Windows do
    subject { described_class.new }

    describe '#memory_free' do
        it 'returns the amount of free memory'
    end

    describe '#cpu_count' do
        it 'returns the amount of CPUs'
    end

    describe '#memory_for_process_group' do
        it 'returns bytes of memory used by the group'
    end

    describe '#kill_group' do
        it 'kills a process group'
    end

    describe '.current?' do
        context 'when running on Windows' do
            it 'returns true'
        end

        context 'when not running on Windows' do
            it 'returns false'
        end
    end
end
