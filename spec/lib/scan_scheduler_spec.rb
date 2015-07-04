describe ScanScheduler do
    subject { described_class.instance }
    let(:site) { FactoryGirl.create :site }
    let(:tick) { described_class::TICK }

    after :each do
        subject.stop
        subject.instances.killall
    end

    def wait
        q = Queue.new
        subject.after_next_tick { q << nil }
        q.pop
    end

    describe '#start' do
        context 'when there are due scans' do
            let(:due) do
                FactoryGirl.create(
                    :scan,
                    site: site,
                    name: 'stuff',
                    schedule_attributes: {
                        start_at: Time.now
                    }
                )
            end

            context 'and there is an available slot' do
                it 'performs them' do
                    expect(subject).to receive( :perform ).with( due )
                    subject.start

                    wait
                end
            end

            context 'and there is no available slot' do
                it 'waits for one before performing them'
            end
        end
    end

    describe '#stop' do
        it 'stops the scheduler' do
            subject.start
            wait
            expect(subject).to be_running

            subject.stop
            expect(subject).to_not be_running
        end
    end

    describe '#running?' do
        context 'when the scheduler is running' do
            before do
                subject.start
                wait
            end

            it 'returns true' do
                expect(subject).to be_running
            end
        end

        context 'when the scheduler is not running' do
            it 'returns true' do
                expect(subject).to_not be_running
            end
        end
    end

end
