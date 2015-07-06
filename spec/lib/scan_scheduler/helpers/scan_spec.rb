describe ScanScheduler::Helpers::Scan do
    subject { ScanScheduler.instance }

    let(:revision) { new_revision }
    let(:scan) do
        FactoryGirl.create(
            :scan,
            site: site,
            profile: profile,
            site_role: site_role,
            schedule: FactoryGirl.create(
                :schedule,
                start_at: Time.now
            )
        )
    end
    let(:user) { FactoryGirl.create :user }
    let(:settings){ FactoryGirl.create :setting }
    let(:profile) { FactoryGirl.create :profile }
    let(:site_role) { FactoryGirl.create :site_role, site: site }
    let(:site) { FactoryGirl.create :site, user: user }
    let(:instance_manager) { MockInstanceManager.new }
    let(:native_issue) { Factory[:issue] }
    let(:tick) { ScanScheduler::TICK }
    let(:instance) do
        instance = nil
        subject.spawn_instance_for( revision ) { |i| instance = i }
        instance
    end

    def new_revision
        FactoryGirl.create :revision, scan: scan
    end

    def wait
        # q = nil
        # subject.after_next_tick { q = true }
        # sleep 0.5 while !q
        sleep tick
    end

    before do
        subject.reset
        allow(subject).to receive(:instances) { instance_manager }
    end

    after :each do
        subject.stop
        subject.instances.killall
    end

    describe "#{described_class}::REPORT_DIR" do
        it 'is a directory' do
            expect(File.directory?( described_class::REPORT_DIR )).to be_truthy
        end
    end

    describe '#suspend' do
        it 'suspends the scan' do
            expect(instance.service).to receive(:suspend)
            subject.suspend( revision )
        end

        it 'sets #snapshot_path' do
            instance
            subject.suspend( revision )

            expect(scan.reload.snapshot_path).to eq '/my/path'
        end
    end

    describe '#pause' do
        it 'pauses the scan' do
            expect(instance.service).to receive(:pause)
            subject.pause( revision )
        end

        it 'passes the response to #handle_if_rpc_error' do
            instance

            expect(subject).to receive(:handle_if_rpc_error).with( revision, nil )
            subject.pause( revision )
        end
    end

    describe '#resume' do
        it 'resumes the scan' do
            expect(instance.service).to receive(:resume)
            subject.resume( revision )
        end

        it 'passes the response to #handle_if_rpc_error' do
            instance

            expect(subject).to receive(:handle_if_rpc_error).with( revision, nil )
            subject.resume( revision )
        end
    end

    describe '#abort' do
        it 'calls #download_report_and_shutdown' do
            instance

            expect(subject).to receive(:download_report_and_shutdown).with( revision )
            subject.abort( revision )
        end
    end

    describe '#perform' do
        before do
            settings
        end

        it 'creates a new revision' do
            expect(scan.revisions.size).to be 0

            subject.perform( scan ) rescue Arachni::Reactor::Error::NotRunning

            expect(scan.revisions.size).to be 1
        end

        it 'spawns an instance' do
            expect(subject.active_instance_count).to be 0

            subject.perform( scan ) rescue Arachni::Reactor::Error::NotRunning

            expect(subject.active_instance_count).to be 1
        end

        it 'starts the scan' do
            expect_any_instance_of(MockInstanceClientService).to receive(:scan).with( scan.rpc_options )
            subject.perform( scan )
        end

        it 'calls #update every TICK seconds' do
            subject.start

            expect(subject).to receive(:update) do |revision|
                expect(revision).to eq scan.revisions.reload.first
            end
            subject.perform( scan )
            wait
            wait
        end

        context 'when the #update call yields' do
            context 'true' do
                it 'cancels the job'
            end

            context 'false' do
                it 'does not cancel the job'
            end
        end

        context 'when the scan is not recurring' do
            before do
                scan.schedule.month_frequency = nil
                scan.schedule.day_frequency = nil
                scan.schedule.save
            end

            it 'destroys the scan schedule' do
                expect(scan.schedule).to be_scheduled

                subject.perform( scan ) rescue Arachni::Reactor::Error::NotRunning

                expect(scan.reload).to_not be_scheduled
            end
        end

        context 'when the scan is recurring' do
            before do
                scan.schedule.month_frequency = 1
                scan.schedule.day_frequency = 2
                scan.schedule.save
            end

            it 'removes the scan from the schedule' do
                expect(scan.schedule).to be_scheduled

                subject.perform( scan ) rescue Arachni::Reactor::Error::NotRunning

                expect(scan.schedule).to_not be_scheduled
            end
        end

        context 'when the #scan response is an RPC exception' do
            let(:exception) { Arachni::RPC::Exceptions::Base.new }

            before do
                allow_any_instance_of(MockInstanceClientService).
                    to receive(:scan).with( scan.rpc_options ) { |&block| block.call exception }
            end

            it 'forwards it to #handle_rpc_error' do
                expect(subject).to receive(:handle_rpc_error) do |revision, e|
                    expect(revision.id).to eq scan.revisions.first.id
                    expect(e).to eq exception
                end

                subject.perform( scan )
            end

            it 'does not setup progress monitoring' do
                expect(subject).to_not receive(:update)

                subject.perform( scan )
                wait
            end
        end
    end

    describe '#update' do
        before do
            instance
        end

        it 'polls for progress' do
            expect(instance.service).to receive(:native_progress)
            subject.update( revision ) {}
        end

        it 'includes issues' do
            expect(instance.service).to receive(:native_progress) do |options|
                expect(options[:with]).to include :issues
            end

            subject.update( revision ) {}
        end

        it 'includes errors'
        it 'includes sitemap entries'

        it 'excludes issues from previous revisions' do
            Issue.create_from_arachni( native_issue, revision: revision )

            expect(instance.service).to receive(:native_progress) do |options|
                expect(options[:without][:issues]).to be_any
                expect(options[:without][:issues]).to eq scan.issues.digests
            end

            subject.update( revision ) {}
        end

        context 'subsequent calls' do
            it 'exclude seen sitemap entries'
            it 'exclude seen errors'

            it 'exclude seen issues' do
                expect(instance.service).to receive(:native_progress) do |_, &block|
                    block.call(
                        busy:   true,
                        issues: [native_issue]
                    )
                end
                subject.update( revision ) {}

                expect(instance.service).to receive(:native_progress) do |options|
                    expect(options[:without][:issues]).to include native_issue.digest
                end
                subject.update( revision ) {}
            end
        end

        context 'when :busy' do
            it 'updates runtime statistics'

            it 'updates revision state' do
                expect(instance.service).to receive(:native_progress) do |_, &block|
                    block.call(
                        busy:   true,
                        issues: [],
                        status: 'stuff'
                    )
                end
                subject.update( revision ) {}

                expect(revision.reload.state).to eq 'stuff'
            end

            context 'and has :issues' do
                it 'creates them' do
                    expect(instance.service).to receive(:native_progress) do |_, &block|
                        block.call(
                            busy:   true,
                            issues: [native_issue]
                        )
                    end

                    expect(Issue).to receive(:create_from_arachni).with(
                        native_issue, revision: revision
                    )

                    subject.update( revision ) {}
                end
            end
        end

        context 'when not :busy' do
            before do
                expect(instance.service).to receive(:native_progress) do |_, &block|
                    block.call( busy: false )
                end
                expect(subject).to receive(:download_report_and_shutdown).with( revision )
            end

            it 'calls #download_report_and_shutdown' do
                subject.update( revision ) {}
            end

            it 'sets Revision#state to nil' do
                subject.update( revision ) {}

                expect(revision.reload.state).to be_nil
            end

            it 'sets Revision#stopped_at' do
                subject.update( revision ) {}

                expect(revision.reload.stopped_at).to be_kind_of Time
            end

            context 'when the scan is recurring' do
                before do
                    scan.schedule.day_frequency = 1
                    scan.schedule.month_frequency = 2
                    scan.schedule.save
                end

                it 'schedules the next run' do
                    expect(scan.schedule).to receive(:schedule_next)

                    subject.update( revision ) {}

                    expect(scan.schedule.reload).to be_scheduled
                end
            end

            context 'when the scan is not recurring' do
                before do
                    scan.schedule.day_frequency = nil
                    scan.schedule.month_frequency = nil
                    scan.schedule.save
                end

                it 'leaves it unscheduled' do
                    expect(scan.schedule).to_not receive(:schedule_next)

                    subject.update( revision ) {}
                end
            end
        end
    end

    describe '#download_report_and_shutdown' do
        let(:report) { Factory[:report].tap { |r| r.options[:url] = 'http://test.com' } }

        before do
            expect(instance.service).to receive(:native_abort_and_report) do |_, &block|
                block.call report
            end
        end

        it 'retrieves the report' do
            subject.download_report_and_shutdown(revision)
        end

        it "stores the report under #{described_class}::REPORT_DIR" do
            subject.download_report_and_shutdown(revision)

            expect(File.exists?(described_class::REPORT_DIR + "/#{revision.id}.afr")).to be_truthy
        end

        it 'passes the report to #import_issues_from_report' do
            expect(subject).to receive(:import_issues_from_report).
                                   with( revision, report )

            subject.download_report_and_shutdown(revision)
        end

        it 'passes the report issue digests to #mark_other_issues_fixed' do
            expect(subject).to receive(:mark_other_issues_fixed).
                                   with( revision, report.issues.map(&:digest) )

            subject.download_report_and_shutdown(revision)
        end

        it 'calls #kill_instance_for' do
            expect(subject).to receive(:kill_instance_for).with(revision)
            subject.download_report_and_shutdown(revision)
        end
    end
end
