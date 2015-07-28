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
                settings.max_parallel_scans = nil
                settings.save
            end

            it 'calculates slots based on available resources' do
                expect(subject).to receive(:slots_memory_free).and_return( 25 )
                expect(subject).to receive(:slots_cpu_free).and_return( 25 )

                expect(subject.slots_free).to eq 25
            end

            context 'when restricted by memory' do
                it 'bases the calculation on memory slots' do
                    expect(subject).to receive(:slots_memory_free).and_return( 10 )
                    expect(subject).to receive(:slots_cpu_free).and_return( 25 )

                    expect(subject.slots_free).to eq 10
                end
            end

            context 'when restricted by CPUs' do
                it 'bases the calculation on CPU slots' do
                    expect(subject).to receive(:slots_memory_free).and_return( 10 )
                    expect(subject).to receive(:slots_cpu_free).and_return( 5 )

                    expect(subject.slots_free).to eq 5
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

    describe '#slots_memory_free' do
        before do
            settings.browser_cluster_pool_size = 6
            settings.save
        end

        it 'returns amount of free memory slots' do
            expect(subject).to receive(:slot_unallocated_memory).and_return( subject.slot_memory_size * 2 )

            expect(subject.slots_memory_free).to eq 2
        end
    end

    describe '#slots_cpu_free' do
        it 'returns amount of free CPUs splots' do
            expect(System).to receive(:cpu_count).and_return( 12 )
            expect(subject).to receive(:slots_used).and_return( 5 )

            expect(subject.slots_cpu_free).to eq 7
        end
    end

    describe '#slot_unallocated_memory' do
        before do
            settings.browser_cluster_pool_size = 6
            settings.save
        end

        context 'when there are no scans running' do
            it 'returns the amount of free memory' do
                free = subject.slot_memory_size * 2

                expect(System.instance).to receive(:memory_free).and_return( free )

                expect(subject.slot_unallocated_memory).to eq free
            end
        end

        context 'when there are scans running' do
            context 'using part of their allocation' do
                it 'removes their allocated slots' do
                    used_allocation = subject.slot_memory_size / 3

                    expect(System.instance).to receive(:memory_free).and_return( subject.slot_memory_size * 2 - used_allocation )

                    expect(Arachni::Processes::Manager.instance).to receive(:pids).and_return([123])
                    expect(subject).to receive(:slot_remaining_memory_for).with(123).and_return( subject.slot_memory_size - used_allocation )

                    expect(subject.slot_unallocated_memory).to eq subject.slot_memory_size
                end
            end
        end
    end

    describe '#slot_remaining_memory_for' do
        it 'returns the amount of allocated memory available to the scan' do
            expect(System.instance).to receive(:memory_for_process_group).with(123).and_return( subject.slot_memory_size / 3 )
            expect(subject.slot_remaining_memory_for(123)).to eq( subject.slot_memory_size - subject.slot_memory_size / 3 )
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
