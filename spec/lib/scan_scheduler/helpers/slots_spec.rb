describe ScanScheduler::Helpers::Slots do
    subject { ScanScheduler.instance }
    let(:settings) { Setting.get }
    let(:instance_manager) { MockInstanceManager.new }

    before do
        subject.reset
        allow(subject).to receive(:instances) { instance_manager }
    end

    after :each do
        subject.stop
        subject.instances.killall
    end

    describe '#slots_free' do
        context 'when Setting#max_parallel_scans is set' do
            before do
                settings.max_parallel_scans = 5
                settings.save
            end

            it 'uses it to calculate available slots' do
                expect(subject.slots_free).to eq 5
            end

            context 'when some slots have been used' do
                it 'subtracts them' do
                    allow(subject).to receive(:slots_used).and_return( 2 )
                    expect(subject.slots_free).to eq 3
                end
            end
        end

        context 'when Setting#max_parallel_scans is not set' do
            before do
                settings.browser_cluster_pool_size = 6
                settings.max_parallel_scans        = nil
                settings.save
            end

            it 'calculates slots based on available resources' do
                expect(System.instance).to receive(:memory_free).and_return( 50 * 1024 * 1024 * 1024 )
                expect(System.instance).to receive(:cpu_count).and_return( 25 )

                expect(subject.slots_free).to eq 25
            end

            context 'when restricted by RAM' do
                it 'uses it to calculate the slots' do
                    expect(System.instance).to receive(:memory_free).and_return( 5 * 1024 * 1024 * 1024 )
                    expect(System.instance).to receive(:cpu_count).and_return( 100 )

                    expect(subject.slots_free).to eq 2
                end
            end

            context 'when restricted by CPUs' do
                it 'uses it to calculate the slots' do
                    expect(System.instance).to receive(:memory_free).and_return( 4000 * 1024 * 1024 * 1024 )
                    expect(System.instance).to receive(:cpu_count).and_return( 2 )

                    expect(subject.slots_free).to eq 2
                end
            end
        end
    end

    describe '#slots_used' do
        it 'returns the amount of active instances' do
            allow(subject).to receive(:active_instance_count).and_return( 2 )
            expect(subject.slots_used).to eq 2
        end
    end

    describe '#slots_total' do
        it 'sums up free and used slots' do
            expect(subject).to receive(:slots_free).and_return( 3 )
            expect(subject).to receive(:slots_used).and_return( 5 )

            expect(subject.slots_total).to eq 8
        end
    end

    describe '#slot_memory_size' do
        before do
            settings.browser_cluster_pool_size = 6
            settings.save
        end

        it 'is approx 2GB with default settings' do
            expect((subject.slot_memory_size / 1024.0 / 1024.0 / 1024.0).round).to eq 2
        end

        context 'when Settings#browser_cluster_pool_size is adjusted' do
            before do
                settings.browser_cluster_pool_size = 6
                settings.save
            end

            it 'adjusts the size' do
                prev = subject.slot_memory_size

                settings.browser_cluster_pool_size = 4
                settings.save

                expect(subject.slot_memory_size).to eq( prev - (2 * described_class::SLOT_BROWSER_SIZE) )
            end
        end
    end
end
