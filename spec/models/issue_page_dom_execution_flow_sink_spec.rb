require 'spec_helper'

describe IssuePageDomExecutionFlowSink do
    expect_it { to belong_to :dom }
    expect_it { to have_many :stackframes }

    describe '.create_from_arachni' do
        let(:arachni_execution_flow_sink) do
            Factory[:execution_flow]
        end

        it "creates a #{described_class} from #{Arachni::Browser::Javascript::TaintTracer::Sink::ExecutionFlow}" do
            sink = described_class.create_from_arachni( arachni_execution_flow_sink ).reload
            expect(sink).to be_valid

            sink.stackframes.each do |frame|
                expect(frame).to be_kind_of IssuePageDomStackFrame
                expect(frame).to be_valid
            end
        end
    end

end
