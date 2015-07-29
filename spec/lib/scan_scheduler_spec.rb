describe ScanScheduler do
    subject { described_class.instance }
    let(:site) { FactoryGirl.create :site }
    let(:tick) { described_class::TICK }
    let(:instance_manager) { MockInstanceManager.new }

    before do
        subject.reset
        allow(subject).to receive(:instances) { instance_manager }
    end

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
        it 'starts processing due scans' do
            allow(subject).to receive(:each_due_scan) { |&b| b.call 'stuff' }
            expect(subject).to receive(:perform).with('stuff')

            subject.start
            wait
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
