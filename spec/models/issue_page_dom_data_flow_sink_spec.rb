require 'spec_helper'

describe IssuePageDomDataFlowSink do
    expect_it { to belong_to :dom }
    expect_it { to have_one(:function).dependent(:destroy) }
    expect_it { to have_many(:stackframes).dependent(:destroy) }

    describe '.create_from_engine' do
        let(:engine_data_flow_sink) do
            Factory[:data_flow]
        end

        it "creates a #{described_class} from #{SCNR::Engine::Browser::Javascript::TaintTracer::Sink::DataFlow}" do
            sink = described_class.create_from_engine(engine_data_flow_sink).reload
            expect(sink).to be_valid

            expect(sink.object).to eq engine_data_flow_sink.object
            expect(sink.tainted_argument_index).to eq engine_data_flow_sink.tainted_argument_index
            expect(sink.taint_value).to eq engine_data_flow_sink.taint

            expect(sink.function).to be_kind_of IssuePageDomFunction
            expect(sink.function).to be_valid

            sink.stackframes.each do |frame|
                expect(frame).to be_kind_of IssuePageDomStackFrame
                expect(frame).to be_valid
            end
        end
    end

end
