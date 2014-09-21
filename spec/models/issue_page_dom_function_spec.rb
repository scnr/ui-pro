require 'spec_helper'

describe IssuePageDomFunction do
    subject { FactoryGirl.create :issue_page_dom_function }

    expect_it { to belong_to :with_dom_function }

    describe '#arguments' do
        it 'is an Array' do
            expect( subject.arguments ).to be_kind_of Array
        end
    end

    describe '.create_from_arachni' do
        let(:arachni_function) do
            Factory[:called_function]
        end

        it "creates a #{described_class} from #{Arachni::Browser::Javascript::TaintTracer::Frame::CalledFunction}" do
            function = described_class.create_from_arachni( arachni_function ).reload
            expect(function).to be_valid

            expect(function.name).to eq arachni_function.name
            expect(function.source).to eq arachni_function.source
            expect(function.arguments).to eq arachni_function.arguments
        end
    end

end
