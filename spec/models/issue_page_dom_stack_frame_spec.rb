require 'spec_helper'

describe IssuePageDomStackFrame do
    expect_it { to belong_to :with_dom_stack_frame }
    expect_it { to have_one(:function).dependent(:destroy) }

    describe '.create_from_engine' do
        let(:engine_stackframe) do
            Factory[:frame]
        end

        it "creates a #{described_class} from #{SCNR::Engine::Browser::Javascript::TaintTracer::Frame}" do
            frame = described_class.create_from_engine(engine_stackframe).reload
            expect(frame).to be_valid

            expect(frame.url).to eq engine_stackframe.url
            expect(frame.line).to eq engine_stackframe.line

            expect(frame.function).to be_kind_of IssuePageDomFunction
            expect(frame.function).to be_valid
        end
    end

end
