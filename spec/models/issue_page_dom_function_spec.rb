require 'spec_helper'

describe IssuePageDomFunction do
    subject { FactoryGirl.create :issue_page_dom_function }

    expect_it { to belong_to :with_dom_function }

    describe '#arguments' do
        it 'is an Array' do
            expect( subject.arguments ).to be_kind_of Array
        end
    end

    describe '.create_from_engine' do
        let(:engine_function) do
            Factory[:called_function]
        end

        it "creates a #{described_class} from #{SCNR::Engine::Browser::Javascript::TaintTracer::Frame::CalledFunction}" do
            function = described_class.create_from_engine(engine_function )

            expect(function.name).to eq engine_function.name
            expect(function.source).to eq engine_function.source
            expect(function.arguments).to eq engine_function.arguments
        end
    end

end
