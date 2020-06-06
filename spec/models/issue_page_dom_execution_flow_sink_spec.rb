require 'spec_helper'

describe IssuePageDomExecutionFlowSink do
    expect_it { to belong_to :dom }
    expect_it { to have_many(:stackframes).dependent(:destroy) }

    describe '.create_from_engine' do
        let(:engine_execution_flow_sink) do
            Factory[:execution_flow]
        end

        it "creates a #{described_class} from #{SCNR::Engine::Browser::Javascript::TaintTracer::Sink::ExecutionFlow}" do
            sink = described_class.create_from_engine(engine_execution_flow_sink)

            sink.stackframes.each do |frame|
                expect(frame).to be_kind_of IssuePageDomStackFrame
                expect(frame).to be_valid
            end
        end
    end

end
