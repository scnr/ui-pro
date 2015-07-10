require 'spec_helper'

describe Schedule do
    subject do
        FactoryGirl.create(
            :scan,
            site: site
        ).schedule
    end
    let(:site) { FactoryGirl.create :site }

    expect_it { to belong_to :scan }

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

    describe '#frozen?' do
        context 'when the scan is suspended' do
            before do
                subject.scan.suspended!
            end

            it 'returns true' do
                expect(subject).to be_frozen
            end
        end

        context 'when the scan is not suspended' do
            it 'returns false' do
                expect(subject).to_not be_frozen
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

    describe 'in_progress?' do
        context 'when there is #start_at' do
            before do
                subject.start_at = Time.now
            end

            it 'returns false' do
                expect(subject).to_not be_in_progress
            end
        end

        context 'when there is no #start_at' do
            before do
                subject.start_at = nil
            end

            it 'returns true' do
                expect(subject).to be_in_progress
            end
        end
    end

    describe '#recurring?' do
        context 'when #day_frequency has been specified' do
            before do
                subject.day_frequency   = 2
                subject.month_frequency = nil
            end

            expect_it { to be_recurring }
        end

        context 'when #month_frequency has been specified' do
            before do
                subject.day_frequency   = nil
                subject.month_frequency = 1
            end

            expect_it { to be_recurring }
        end

        context 'when no #day_frequency nor #month_frequency have been specified' do
            before do
                subject.day_frequency   = nil
                subject.month_frequency = nil
            end

            expect_it { to_not be_recurring }
        end
    end

    describe '#interval' do
        it 'returns the seconds till next occurrence' do
            subject.day_frequency   = 2
            subject.month_frequency = 3

            now = Time.now
            expect((now + subject.interval).to_s).to eq(
                (now + subject.day_frequency.days +
                    subject.month_frequency.months
                ).to_s)
        end
    end

    describe '#schedule_next' do
        context 'if #recurring?' do
            before do
                subject.day_frequency   = 3
                subject.month_frequency = 2
            end

            it 'sets the next #start_at' do
                subject.start_at = Time.now - 1000
                subject.schedule_next

                expect(subject.start_at.to_s).to eq Time.zone.now.advance(
                    months: subject.month_frequency,
                    days:   subject.day_frequency
                ).to_s
            end
        end

        context 'if not #recurring?' do
            before do
                subject.day_frequency   = nil
                subject.month_frequency = nil
            end

            it 'does nothing' do
                start_at = Time.zone.now
                subject.start_at = start_at
                subject.schedule_next

                expect(subject.start_at.to_s).to eq start_at.to_s
            end
        end
    end
end
