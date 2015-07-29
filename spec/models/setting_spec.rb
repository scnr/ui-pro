require 'rails_helper'

describe Setting, type: :model do
    subject { Setting.get }
    let(:site) { FactoryGirl.create :site }

    describe :validations do
        describe '#max_parallel_scans' do
            context 'when its value is nil' do
                it 'is valid' do
                    subject.max_parallel_scans = nil

                    expect(subject).to be_valid
                end
            end

            context 'when its value is greater than 0' do
                it 'is valid' do
                    subject.max_parallel_scans = 1

                    expect(subject).to be_valid
                end
            end

            context 'when its value is less than an equivalent site setting' do
                before do
                    site.max_parallel_scans = 2
                    site.save
                end

                it 'is invalid' do
                    subject.max_parallel_scans = 1

                    expect(subject).to be_invalid
                    expect(subject.errors).to include :max_parallel_scans
                end
            end

            context 'when its value is 0' do
                it 'is invalid' do
                    subject.max_parallel_scans = 0

                    expect(subject).to be_invalid
                    expect(subject.errors).to include :max_parallel_scans
                end
            end

            context 'when its value is less than 0' do
                it 'is invalid' do
                    subject.max_parallel_scans = -1

                    expect(subject).to be_invalid
                    expect(subject.errors).to include :max_parallel_scans
                end
            end
        end
    end

    describe '#max_parallel_scans_auto?' do
        context 'when #max_parallel_scans is nil' do
            before do
                subject.max_parallel_scans = nil
                subject.save
            end

            it 'returns true' do
                expect(subject).to be_max_parallel_scans_auto
            end
        end

        context 'when #max_parallel_scans is not nil' do
            before do
                subject.max_parallel_scans = 1
                subject.save
            end

            it 'returns false' do
                expect(subject).to_not be_max_parallel_scans_auto
            end
        end
    end
end
