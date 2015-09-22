require 'spec_helper'

describe Schedule do
    subject do
        FactoryGirl.create(
            :scan,
            site: site,
        ).schedule
    end
    let(:site) { FactoryGirl.create :site, user: user }
    let(:revision) { FactoryGirl.create :revision, scan: subject.scan }
    let(:user) { FactoryGirl.create :user }

    expect_it { to belong_to :scan }

    it 'sets #frequency_base to start' do
        expect(Schedule.create.frequency_base).to eq 'start'
    end

    it 'ensures #start_at is not in the past' do
        t = Time.now

        subject.start_at = Time.now - 1000
        subject.save

        expect(subject.start_at).to be > t
        expect(subject.start_at).to be < Time.now
    end

    describe 'scopes' do
        let(:due) do
            [
                FactoryGirl.create( :scan,
                                    site: site,
                                    name: 'stuff',
                                    schedule_attributes: {
                                        start_at: Time.now
                                    }
                ).schedule,
                FactoryGirl.create( :scan,
                                    site: site,
                                    name: 'stuff2',
                                    schedule_attributes: {
                                        start_at: Time.now
                                    }
                ).schedule
            ]
        end

        let(:not_due) do
            [
                FactoryGirl.create( :scan,
                                    site: site,
                                    name: 'stuff3',
                                    schedule_attributes: {
                                        start_at: Time.now + 10000
                                    }
                ).schedule,
                FactoryGirl.create( :scan,
                                    site: site,
                                    name: 'stuff4',
                                    schedule_attributes: {
                                        start_at: Time.now + 10000
                                    }
                ).schedule,
                FactoryGirl.create( :scan,
                                    site: site,
                                    name: 'stuff5'
                )
            ]
        end

        describe 'due' do
            it 'returns scans that are due' do
                due
                not_due

                expect(described_class.due).to eq due
            end
        end
    end

    describe 'validations' do
        describe '#frequency_base' do
            it 'allows start' do
                subject.frequency_base = 'start'

                expect(subject.save).to be_truthy
            end

            it 'allows stop' do
                subject.frequency_base = 'stop'

                expect(subject.save).to be_truthy
            end

            it 'does not allow other values' do
                subject.frequency_base = 'stuff'

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :frequency_base
            end
        end

        describe '#frequency_format' do
            it 'allows simple' do
                subject.frequency_format = 'simple'

                expect(subject.save).to be_truthy
            end

            it 'allows cron' do
                subject.frequency_format = 'cron'

                expect(subject.save).to be_truthy
            end

            it 'does not allow other values' do
                subject.frequency_format = 'stuff'

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :frequency_format
            end
        end

        describe '#frequency_cron' do
            context 'when frequency_format is' do
                context 'cron' do
                    before do
                        subject.frequency_format = 'cron'
                    end

                    it 'accepts valid cronlines' do
                        subject.frequency_cron = '* * * * *'

                        expect(subject.save).to be_truthy
                    end

                    it 'does not allow invalid cronlines' do
                        subject.frequency_cron = 'stuff'

                        expect(subject.save).to be_falsey
                        expect(subject.errors).to include :frequency_cron
                    end
                end

                context 'simple' do
                    before do
                        subject.frequency_format = 'simple'
                    end

                    it 'accepts valid cronlines' do
                        subject.frequency_cron = '* * * * *'

                        expect(subject.save).to be_truthy
                    end

                    it 'accepts invalid cronlines' do
                        subject.frequency_cron = 'stuff'

                        expect(subject.save).to be_truthy
                    end
                end
            end
        end

        describe '#day_frequency' do
            it 'is numeric' do
                subject.day_frequency = 'stuff'

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :day_frequency
            end

            it 'is is within 1 and 29' do
                subject.day_frequency = 0

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :day_frequency

                subject.day_frequency = 30

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :day_frequency

                (1..29).each do |i|
                    subject.day_frequency = i
                    expect(subject.save).to be_truthy
                end
            end

            it 'can be nil' do
                subject.day_frequency = nil
                expect(subject.save).to be_truthy
            end
        end

        describe '#month_frequency' do
            it 'is numeric' do
                subject.month_frequency = 'stuff'

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :month_frequency
            end

            it 'is is within 1 and 12' do
                subject.month_frequency = 0

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :month_frequency

                subject.month_frequency = 13

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :month_frequency

                (1..12).each do |i|
                    subject.month_frequency = i
                    expect(subject.save).to be_truthy
                end
            end

            it 'can be nil' do
                subject.month_frequency = nil
                expect(subject.save).to be_truthy
            end
        end

        describe '#start_at' do
            it 'is a datetime' do
                subject.start_at = 'stuff'

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :start_at
            end

            it 'is in the future' do
                subject.start_at = Time.now + 1000

                expect(subject.save).to be_truthy
            end

            it 'can be nil' do
                subject.start_at = nil
                expect(subject.save).to be_truthy
            end

            context 'when it is in the past' do
                it 'is set to the present' do
                    subject.start_at = 1.month.ago

                    expect(subject.save).to be_truthy
                    expect(subject.start_at.strftime('%F')).to eq subject.start_at.strftime('%F')
                end
            end
        end
    end

    describe '#unschedule' do
        it 'sets #start_at to nil' do
            subject.start_at = Time.now
            subject.unschedule
            expect(subject.start_at).to be_nil
        end
    end

    describe '#scheduled?' do
        context 'when #start_at is not nil' do
            it 'returns true' do
                subject.start_at = Time.now
                expect(subject).to be_scheduled
            end
        end

        context 'when #start_at is nil' do
            it 'returns false' do
                subject.start_at = nil
                expect(subject).to_not be_scheduled
            end
        end
    end

    describe '#suspended?' do
        context 'when the scan is suspended' do
            before do
                revision.suspended!
            end

            it 'returns true' do
                expect(subject).to be_suspended
            end
        end

        context 'when the scan is not suspended' do
            it 'returns false' do
                expect(subject).to_not be_suspended
            end
        end
    end

    describe '#due?' do
        context 'when there is #start_at' do
            context 'in the past' do
                before do
                    subject.start_at = Time.now
                end

                it 'returns true' do
                    expect(subject).to be_due
                end
            end

            context 'in the future' do
                before do
                    subject.start_at = Time.now + 1000
                end

                it 'returns false' do
                    expect(subject).to_not be_due
                end
            end
        end

        context 'when there is no #start_at' do
            before do
                subject.start_at = nil
            end

            it 'returns true' do
                expect(subject).to_not be_due
            end
        end
    end

    describe '#recurring?' do
        context 'when #frequency_simple? is true' do
            before do
                allow(subject). to receive(:frequency_simple?) { true }
            end

            expect_it { to be_recurring }
        end

        context 'when #frequency_cron? is true' do
            before do
                allow(subject). to receive(:frequency_cron?) { true }
            end

            expect_it { to be_recurring }
        end

        context 'when no #frequency_simple? nor #frequency_cron? are true' do
            before do
                allow(subject). to receive(:frequency_simple?) { false }
                allow(subject). to receive(:frequency_cron?) { false }
            end

            expect_it { to_not be_recurring }
        end
    end

    describe '#frequency_simple?' do
        context 'when #frequency_format is' do
            context 'cron' do
                before do
                    subject.frequency_format = 'cron'
                end

                expect_it { to_not be_frequency_simple }
            end

            context 'simple' do
                before do
                    subject.frequency_base = 'simple'
                end

                context 'with #day_frequency' do
                    before do
                        subject.day_frequency = 1
                    end

                    expect_it { to be_frequency_simple }
                end

                context 'with #month_frequency' do
                    before do
                        subject.month_frequency = 1
                    end

                    expect_it { to be_frequency_simple }
                end
            end
        end
    end

    describe '#frequency_cron?' do
        context 'when #frequency_format is' do
            context 'simple' do
                before do
                    subject.frequency_format = 'simple'
                end

                expect_it { to_not be_frequency_cron }
            end

            context 'cron' do
                before do
                    subject.frequency_format = 'cron'
                end

                context 'without #frequency_cron' do
                    before do
                        subject.frequency_cron = nil
                    end

                    expect_it { to_not be_frequency_cron }
                end

                context 'with #frequency_cron' do
                    before do
                        subject.frequency_cron = '@monthly'
                    end

                    expect_it { to be_frequency_cron }
                end
            end
        end
    end

    describe '#frequency_based_on_start_time?' do
        context 'when #frequency_base is' do
            context 'start' do
                before do
                    subject.frequency_base = 'start'
                end

                expect_it { to be_frequency_based_on_start_time }
            end

            context 'stop' do
                before do
                    subject.frequency_base = 'stop'
                end

                expect_it { to_not be_frequency_based_on_start_time }
            end
        end
    end

    describe '#static?' do
        it 'is aliased to #frequency_based_on_start_time?' do
            ret = 'stuff'
            allow(subject).to receive(:frequency_based_on_start_time?).and_return( ret )
            expect(subject.static?).to be ret
        end
    end

    describe '#frequency_based_on_stop_time?' do
        context 'when #frequency_base is' do
            context 'start' do
                before do
                    subject.frequency_base = 'start'
                end

                expect_it { to_not be_frequency_based_on_stop_time }
            end

            context 'stop' do
                before do
                    subject.frequency_base = 'stop'
                end

                expect_it { to be_frequency_based_on_stop_time }
            end
        end
    end

    describe '#dynamic?' do
        it 'is aliased to #frequency_based_on_stop_time?' do
            ret = 'stuff'
            allow(subject).to receive(:frequency_based_on_stop_time?).and_return( ret )
            expect(subject.dynamic?).to be ret
        end
    end

    describe '#step_through' do
        context 'when no block is given' do
            it 'raises an exception' do
                expect do
                    subject.step_through
                end.to raise_error 'Missing block.'
            end
        end

        context 'when the scan is not scheduled' do
            before do
                subject.start_at = nil
            end

            it 'raises an exception' do
                expect do
                    subject.step_through {}
                end.to raise_error 'Not scheduled.'
            end
        end

        context 'when the scan is scheduled' do
            before do
                subject.start_at = Time.now + 1000
            end

            context 'and recurring' do
                before do
                    subject.frequency_format = 'simple'
                    subject.day_frequency    = 1
                end

                context 'and static' do
                    before do
                        subject.frequency_base = 'start'
                    end

                    it 'projects 12 next occurrences of the scan' do
                        cnt = 0

                        subject.step_through do |occurrence, time|
                            cnt += 1

                            if cnt == 1
                                expect(time.to_s).to eq subject.start_at.to_s
                            else
                                expect(time.to_s).to eq (subject.start_at + (cnt - 1).days).to_s
                            end

                            expect(occurrence).to eq cnt
                        end

                        expect(cnt).to eq 12
                    end

                    context 'when the amount of steps has been specified' do
                        it 'projects the given amount of occurrences' do
                            steps = 100
                            cnt   = 0

                            subject.step_through steps do |occurrence, time|
                                cnt += 1

                                if cnt == 1
                                    expect(time.to_s).to eq subject.start_at.to_s
                                else
                                    expect(time.to_s).to eq (subject.start_at + (cnt - 1).days).to_s
                                end

                                expect(occurrence).to eq cnt
                            end

                            expect(cnt).to eq steps
                        end
                    end

                    context 'when the scan has revisions' do
                        it 'accounts for them in the occurrence index' do
                            steps = 100
                            cnt   = 0

                            subject.scan.revisions.create
                            subject.scan.revisions.create

                            subject.step_through steps do |occurrence, time|
                                cnt += 1
                                expect(occurrence).to eq cnt + 2
                            end

                            expect(cnt).to eq steps
                        end
                    end
                end

                context 'and dynamic' do
                    before do
                        subject.frequency_base = 'stop'
                    end

                    it 'only yields the first occurrence' do
                        cnt = 0

                        subject.step_through do |occurrence, time|
                            cnt += 1

                            expect(time.to_s).to eq subject.start_at.to_s
                            expect(occurrence).to eq cnt
                        end

                        expect(cnt).to eq 1
                    end
                end
            end

            context 'and not recurring' do
                before do
                    subject.frequency_format = nil
                end

                it 'only yields the first occurrence' do
                    cnt = 0

                    subject.step_through do |occurrence, time|
                        cnt += 1

                        expect(time.to_s).to eq subject.start_at.to_s
                        expect(occurrence).to eq cnt
                    end

                    expect(cnt).to eq 1
                end
            end
        end
    end

    describe '#next' do
        let(:time) { Time.now + 3.days }

        context 'when not #recurring?' do
            before do
                allow(subject).to receive(:recurring?) { false }
            end

            it 'returns nil' do
                expect(subject.next( time )).to be_nil
            end
        end

        context 'when #frequency_cron?' do
            before do
                subject.frequency_cron   = '@monthly'
                subject.frequency_format = 'cron'
            end

            it 'returns the next occurrence from on #frequency_cron' do
                expect(subject.next( time ).to_s).to eq (time + 1.month).at_beginning_of_month.to_s
            end
        end

        context 'when #frequency_simple?' do
            before do
                subject.day_frequency   = 1
                subject.month_frequency = 2

                subject.frequency_format = 'simple'
            end

            it 'returns the next occurrence from on the simple frequency' do
                expect(subject.next( time ).to_s).to eq (time + 1.days + 2.months).to_s
            end
        end

        context 'when the next immediate occurrence is in the past' do
            before do
                subject.day_frequency = 1
                subject.frequency_format = 'simple'
            end

            let(:time) { Time.now - 3.months }

            it 'returns the future occurrence closest to now' do
                expect(subject.next( time ).to_s).to eq (time  + 1.day + 3.months).to_s
            end
        end
    end

    describe '#schedule_next' do
        let(:started_at) { Time.now.utc - 1000 }
        let(:stopped_at) { started_at + 3500 }

        before do
            subject.scan.revisions.create(
                started_at: started_at,
                stopped_at: stopped_at
            )
        end

        context 'when not #recurring?' do
            before do
                allow(subject).to receive(:recurring?) { false }
            end

            it 'returns nil' do
                expect(subject.schedule_next).to be_nil
            end
        end

        context 'when #frequency_based_on_start_time? is' do
            before do
                allow(subject).to receive(:recurring?) { true }
            end

            context 'true' do
                before do
                    allow(subject).to receive(:frequency_based_on_start_time?) { true }
                end

                it "calculates #start_at based on the last revision's #started_at" do
                    expect(subject).to receive(:next) { |time| expect(time.to_s).to eq started_at.to_s }

                    subject.schedule_next
                end
            end

            context 'false' do
                before do
                    allow(subject).to receive(:frequency_based_on_start_time?) { false }
                end

                it "calculates #start_at based on the last revision's #stoppedd_at" do
                    expect(subject).to receive(:next) { |time| expect(time.to_s).to eq stopped_at.to_s }

                    subject.schedule_next
                end
            end
        end
    end
end
