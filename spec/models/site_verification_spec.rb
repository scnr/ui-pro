require 'rails_helper'

describe SiteVerification, type: :model do
    subject { FactoryGirl.create :site_verification }
    let(:other_subject) { FactoryGirl.create :site_verification }

    VALID_STATE_TYPES = [:done]
    VALID_STATES = [:failed, :verified, :error, :pending, :started]

    expect_it { to belong_to :site }

    describe '#url' do
        it 'returns the URL of the verification file' do
            site = FactoryGirl.create(:site)
            expect(site.verification.url).to eq "#{site.url}/#{site.verification.filename}"
        end
    end

    describe '#filename' do
        it 'is set by default' do
            expect(subject.filename).to end_with '.txt'
        end

        it 'is random' do
            expect(other_subject.filename).to_not eq subject.filename
        end
    end

    describe '#code' do
        it 'is set by default' do
            expect(subject.code).to_not be_empty
        end

        it 'is random' do
            expect(other_subject.code).to_not eq subject.code
        end
    end

    describe '#state' do
        it 'defaults to :pending' do
            expect(subject.state).to eq :pending
        end
    end

    describe '#message=' do
        it 'sets the #message' do
            subject.message = 'Stuff'
            expect(subject.message).to eq 'Stuff'
        end
    end

    VALID_STATES.each do |state|
        describe "##{state}!" do
            it "sets #state to #{state}" do
                subject.send("#{state}!")
                expect(subject.state).to eq state.to_sym
            end
        end

        describe "##{state}?" do
            context 'when state is' do
                context state do
                    before { subject.state = state.to_sym }
                    expect_it { to send("be_#{state}") }
                end

                VALID_STATES.each do |s|
                    next if s == state

                    context s do
                        before { subject.state = s }
                        expect_it { to_not send("be_#{state}") }
                    end
                end
            end
        end
    end

    VALID_STATE_TYPES.each do |type|
        describe "##{type}?" do
            context 'when state is' do
                described_class::STATES_BY_TYPE[type].each do |state|
                    context state do
                        before { subject.state = state }
                        expect_it { to send("be_#{type}") }
                    end
                end

                (VALID_STATES - described_class::STATES_BY_TYPE[type].to_a).each do |s|
                    context s do
                        before { subject.state = s }
                        expect_it { to_not send("be_#{type}") }
                    end
                end
            end
        end
    end

end
