describe ScanScheduler::Helpers::Scan do
    subject { ScanScheduler.instance }

    let(:other_site) { FactoryGirl.create :site, user: user }
    let(:other_scan) do
        FactoryGirl.create(
            :scan,
            site: other_site,
            profile: profile,
            site_role: site_role,
            schedule: FactoryGirl.create(
                      :schedule,
                      start_at: Time.now
                  )
        )
    end

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
    let(:settings){ Setting.get }
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
        before do
            instance
            expect(subject).to receive(:stop_monitor).with( revision )
            expect(subject).to receive(:download_report_and_shutdown).
                                   with( revision, { mark_issues_fixed: false, status: 'aborted' } )
        end

        it 'sets status to aborting' do
            subject.abort( revision )
            expect(scan).to be_aborting
        end

        it 'aborts progress monitoring' do
            instance
            subject.abort( revision )
        end

        it 'calls #download_report_and_shutdown' do
            instance
            subject.abort( revision )
        end
    end

    describe '#each_due_scan' do
        context 'when there are due scans' do
            before do
                FactoryGirl.create(
                    :scan,
                    site: site,
                    schedule_attributes: {
                        start_at: Time.now + 1000
                    }
                )
            end

            let(:due) do
                FactoryGirl.create(
                    :scan,
                    site: site,
                    schedule_attributes: {
                        start_at: Time.now
                    }
                )
            end

            let(:other_site_due) do
                FactoryGirl.create(
                    :scan,
                    site: other_site,
                    schedule_attributes: {
                        start_at: Time.now
                    }
                )
            end

            context 'and there are available slots' do
                it 'yields them' do
                    other_site_due
                    due

                    s = []
                    subject.each_due_scan do |scan|
                        s << scan
                    end

                    expect(s).to eq [other_site_due, due]
                end
            end

            context 'and there are not enough slots left' do
                before do
                    allow(subject).to receive(:slots_free).and_return(1)
                end

                it 'yields as many as possible' do
                    other_site_due
                    due

                    s = []
                    subject.each_due_scan do |scan|
                        s << scan
                    end

                    expect(s).to eq [other_site_due]
                end
            end

            context 'and there are no slots left' do
                before do
                    allow(subject).to receive(:slots_free).and_return(0)
                end

                it 'yields nothing' do
                    other_site_due
                    due

                    s = nil
                    subject.each_due_scan do |scan|
                        s = scan
                    end

                    expect(s).to be_nil
                end
            end

            context 'and the site max parallel scans limit has been reached' do
                before do
                    due.site.max_parallel_scans = 1
                    due.site.save

                    allow(subject).to receive(:active_instance_count_for_site) { |s| s == site ? 1 : 0 }
                end

                it 'does not yield the scans for that site' do
                    other_site_due
                    due

                    s = []
                    subject.each_due_scan do |scan|
                        s << scan
                    end

                    expect(s).to eq [other_site_due]
                end
            end
        end
    end

    describe '#perform' do
        before do
            settings
        end

        it 'sets the Revision#started_at to Schedule#start_at' do
            start_at = Time.now + 1199

            scan.schedule.start_at = start_at
            scan.save

            subject.perform( scan ) rescue Arachni::Reactor::Error::NotRunning

            expect(scan.last_revision.started_at.to_i).to eq start_at.to_i
        end

        it 'sets status to initializing' do
            subject.perform( scan ) rescue Arachni::Reactor::Error::NotRunning

            expect(scan).to be_initializing
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

        it 'sets up progress monitoring' do
            subject.start

            expect(subject).to receive(:monitor) do |revision|
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
                expect(subject).to_not receive(:monitor)

                subject.perform( scan )
                wait
            end
        end
    end

    describe '#finish' do
        it 'sets Revision#stopped_at' do
            subject.finish( revision ) {}

            expect(revision.reload.stopped_at).to be_kind_of Time
        end

        context 'when the scan is recurring' do
            before do
                scan.schedule.day_frequency = 1
                scan.schedule.month_frequency = 2
                scan.schedule.save
            end

            context 'when the scan has not been suspended' do
                it 'schedules the next run' do
                    expect(scan).to receive(:schedule_next)

                    subject.finish( revision ) {}

                    expect(scan.schedule.reload).to be_scheduled
                end
            end

            context 'when the scan has been suspended' do
                before do
                    scan.suspended!
                end

                it 'leaves it unscheduled' do
                    expect(scan).to_not receive(:schedule_next)

                    subject.finish( revision ) {}
                end
            end
        end

        context 'when the scan is not recurring' do
            before do
                scan.schedule.day_frequency = nil
                scan.schedule.month_frequency = nil
                scan.schedule.save
            end

            it 'leaves it unscheduled' do
                expect(scan).to_not receive(:schedule_next)

                subject.finish( revision ) {}
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

                expect(scan.reload.status).to eq 'stuff'
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
                expect(subject).to receive(:stop_monitor).with( revision )
            end

            context 'when the scan has not been suspended' do
                before do
                    expect(instance.service).to receive(:native_progress) do |_, &block|
                        block.call( busy: false )
                    end
                    expect(subject).to receive(:download_report_and_shutdown).with(
                                           revision,  status: 'completed' )
                end

                it 'calls #download_report_and_shutdown' do
                    subject.update( revision ) {}
                end

                it 'sets Scan#status to nil' do
                    subject.update( revision ) {}

                    expect(scan.reload.status).to be_nil
                end
            end

            context 'when the scan has been suspended' do
                before do
                    expect(instance.service).to receive(:native_progress) do |_, &block|
                        block.call( busy: false, status: :suspended )
                    end
                end

                it 'sets scan status to suspended' do
                    subject.update( revision )

                    expect(scan.reload).to be_suspended
                end

                it 'sets #snapshot_path' do
                    subject.update( revision )

                    expect(scan.reload.snapshot_path).to eq '/my/path'
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

        it 'calls #finish' do
            expect(subject).to receive(:finish).with( revision )

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

        it 'calls #kill_instance_for' do
            expect(subject).to receive(:kill_instance_for).with(revision)
            subject.download_report_and_shutdown(revision)
        end

        context 'when :status is given' do
            it 'sets it' do
                subject.download_report_and_shutdown( revision, status: 'completed' )
                expect(scan).to be_completed
            end
        end

        context 'when :status is not given' do
            it 'does not affect the status' do
                scan.paused!
                subject.download_report_and_shutdown( revision )
                expect(scan).to be_paused
            end
        end

        context 'when :mark_issues_fixed is' do
            context 'true' do
                context 'and the scan has more than 1 revision' do
                    before do
                        new_revision
                    end

                    it 'passes the report issue digests to #mark_other_issues_fixed' do
                        expect(subject).to receive(:mark_other_issues_fixed).
                                               with( revision, report.issues.map(&:digest) )

                        subject.download_report_and_shutdown( revision, mark_issues_fixed: true )
                    end
                end

                context 'and has 1 revision' do
                    it 'does not call #mark_other_issues_fixed' do
                        expect(subject).to_not receive(:mark_other_issues_fixed)

                        subject.download_report_and_shutdown(revision)
                    end
                end
            end

            context 'false' do
                context 'and has 1 revision' do
                    it 'does not call #mark_other_issues_fixed' do
                        expect(subject).to_not receive(:mark_other_issues_fixed)

                        subject.download_report_and_shutdown( revision, mark_issues_fixed: true )
                    end
                end
            end
        end
    end
end
