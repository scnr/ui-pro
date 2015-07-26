describe ScanScheduler::Helpers::Instance do
    subject { ScanScheduler.instance }

    let(:revision) { new_revision }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }
    let(:instance_manager) { MockInstanceManager.new }

    let(:instance) do
        instance = nil
        subject.spawn_instance_for( revision ) { |i| instance = i }
        instance
    end

    def new_revision
        FactoryGirl.create :revision, scan: scan
    end

    before do
        allow(subject).to receive(:instances) { instance_manager }
    end

    before do
        subject.reset
    end

    after :each do
        subject.stop
        subject.instances.killall
    end

    describe '#active_instance_count' do
        it 'returns the amount of live instances' do
            revisions = []

            # Increase on spawn
            10.times do |i|
                revision = new_revision
                revisions << revision

                subject.spawn_instance_for( revision ){}
                expect(subject.active_instance_count).to be i + 1
            end

            # Decrease on kill
            while (revision = revisions.pop)
                subject.kill_instance_for( revision )
                expect(subject.active_instance_count).to be revisions.size
            end
        end
    end

    describe '#active_instance_count_for_site' do
        it 'returns the amount of live instances for the given site' do
            revisions = []

            # Increase on spawn
            10.times do |i|
                revision = new_revision
                revisions << revision

                subject.spawn_instance_for( revision ){}
                expect(subject.active_instance_count_for_site(site)).to be i + 1
            end

            # Decrease on kill
            while (revision = revisions.pop)
                subject.kill_instance_for( revision )
                expect(subject.active_instance_count_for_site(site)).to be revisions.size
            end
        end
    end

    describe '#spawn_instance_for' do
        it 'spawns an instance' do
            expect(instance).to be_kind_of MockInstanceClient
        end
    end

    describe '#kill_instance_for' do
        it 'kills a spawned instance' do
            expect(subject.instances).to receive(:kill).with(instance.url)
            subject.kill_instance_for revision
        end
    end

    describe '#instance_for' do
        it 'kills a spawned instance' do
            instance
            expect(subject.instance_for( revision )).to eq instance
        end

        context 'when the instance does not exist' do
            it "raises #{described_class::Error::InstanceNotFound}" do
                expect do
                    subject.instance_for( new_revision )
                end.to raise_error described_class::Error::InstanceNotFound
            end
        end
    end
end
