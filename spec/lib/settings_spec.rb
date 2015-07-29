describe Settings do
    subject { described_class }

    describe '.new' do
        it 'raises error' do
            expect do
                subject.new
            end.to raise_error 'Cannot initialize.'
        end
    end

    describe '.record' do
        it 'returns the first Setting record' do
            expect(subject.record).to be_kind_of Setting
        end
    end
end
