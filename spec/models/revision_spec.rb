require 'spec_helper'

describe Revision do
    subject { FactoryGirl.create :revision, scan: scan }
    let(:other_revision) { FactoryGirl.create :revision, scan: scan }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }

    expect_it { to belong_to(:scan).counter_cache(true) }
    expect_it { to have_many(:issues).dependent(:destroy) }
    expect_it { to have_many(:sitemap_entries) }

    describe 'scopes' do
        describe 'in_progress' do
            it 'returns running revisions' do
                running = []

                running << FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: nil
                )
                running << FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 1000,
                    stopped_at: nil
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 2000,
                    stopped_at: Time.now + 3000,
                )
                running << FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 2000,
                    stopped_at: nil
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: Time.now + 4000
                )

                expect(described_class.in_progress).to eq running
            end
        end
    end

    describe '.last_performed' do
        context 'when there are stopped revisions' do
            before do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: nil
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 1000,
                    stopped_at: nil
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 2000,
                    stopped_at: Time.now + 3000,
                )
                last_performed
            end
            let(:last_performed) do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: Time.now + 4000
                )
            end

            it 'returns the latest' do
                expect(described_class.last_performed).to eq last_performed
            end
        end

        context 'when there are no stopped revisions' do
            before do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: nil
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 1000,
                    stopped_at: nil
                )
            end

            it 'returns nil' do
                expect(described_class.last_performed).to be_nil
            end
        end

        context 'when there are no revisions' do
            it 'returns nil' do
                expect(described_class).to_not be_any
                expect(described_class.last_performed).to be_nil
            end
        end
    end

    describe '.last_performed_at' do
        context 'when there are stopped revisions' do
            before do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: nil
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 1000,
                    stopped_at: nil
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 2000,
                    stopped_at: Time.now + 3000,
                )
                last_performed
            end
            let(:last_performed) do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: Time.now + 4000
                )
            end

            it 'returns the time the last revision was performed' do
                expect(described_class.last_performed_at.to_s).to eq last_performed.performed_at.to_s
            end
        end

        context 'when there are no stopped revisions' do
            before do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: nil
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 1000,
                    stopped_at: nil
                )
            end

            it 'returns nil' do
                expect(described_class.last_performed_at).to be_nil
            end
        end

        context 'when there are no revisions' do
            it 'returns nil' do
                expect(described_class).to_not be_any
                expect(described_class.last_performed_at).to be_nil
            end
        end
    end

    describe '.in_progress?' do
        context 'when there is a started but not stopped revision' do
            before do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: nil
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 1000,
                    stopped_at: Time.now + 2000
                )
            end

            it 'returns true' do
                expect(described_class).to be_in_progress
            end
        end

        context 'when there is a started and stopped revision' do
            before do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: Time.now + 3000
                )
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now + 1000,
                    stopped_at: Time.now + 2000
                )
            end

            it 'returns false' do
                expect(described_class).to_not be_in_progress
            end
        end

        context 'when there is not a started and nor stopped revision' do
            before do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: nil,
                    stopped_at: nil
                )
            end

            it 'returns false' do
                expect(described_class).to_not be_in_progress
            end
        end
    end

    describe '#stopped?' do
        context 'when there is a stop time' do
            before do
                subject.stopped_at = Time.now
                subject.save
            end

            it 'returns true' do
                expect(subject).to be_stopped
            end
        end

        context 'when there is no stop time' do
            before do
                subject.stopped_at = nil
                subject.save
            end

            it 'returns true' do
                expect(subject).to_not be_stopped
            end
        end
    end

    describe '#in_progress?' do
        context 'when started but not stopped' do
            subject do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: nil
                )
            end

            it 'returns true' do
                expect(subject).to be_in_progress
            end
        end

        context 'when started and stopped revision' do
            subject do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now,
                    stopped_at: Time.now + 3000
                )
            end

            it 'returns false' do
                expect(subject).to_not be_in_progress
            end
        end

        context 'when not a started nor stopped' do
            subject do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: nil,
                    stopped_at: nil
                )
            end

            it 'returns false' do
                expect(subject).to_not be_in_progress
            end
        end
    end

    describe '#duration' do
        context 'when not started' do
            subject do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: nil,
                    stopped_at: nil
                )
            end

            it 'returns nil' do
                expect(subject.duration).to be_nil
            end
        end

        context 'when not finished' do
            subject do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now - 1000,
                    stopped_at: nil
                )
            end

            it 'returns duration from start time until now' do
                expect(subject.duration.to_i).to eq 1000
            end
        end

        context 'when finished' do
            subject do
                FactoryGirl.create(
                    :revision,
                    scan: scan,
                    started_at: Time.now - 1000,
                    stopped_at: Time.now + 1000,
                )
            end

            it 'returns duration from start time until stop time' do
                expect(subject.duration.to_i).to eq 2000
            end
        end
    end

    describe '#performed_at' do
        subject do
            FactoryGirl.create(
                :revision,
                scan: scan,
                started_at: Time.now - 1000,
                stopped_at: Time.now + 1000,
            )
        end

        it 'returns #stopped_at' do
            expect(subject.performed_at.object_id).to eq subject.stopped_at.object_id
        end
    end

    describe '#index' do
        it 'returns the index of the revision' do
            expect(subject.index).to eq 1
            expect(other_revision.index).to eq 2
        end
    end

    describe '#to_s' do
        it 'returns the index' do
            expect(subject.to_s).to eq "Revision ##{subject.index}"
        end
    end
end
