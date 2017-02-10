require 'spec_helper'

describe IssuePageDom do
    expect_it { to belong_to :page }
    expect_it { to have_many(:transitions).dependent(:destroy) }
    expect_it { to have_many(:data_flow_sinks).dependent(:destroy) }
    expect_it { to have_many(:execution_flow_sinks).dependent(:destroy) }

    describe '.create_from_engine' do
        let(:engine_page_dom) do
            Factory[:dom]
        end

        it "creates a #{described_class} from #{SCNR::Engine::Page::DOM}" do
            dom = described_class.create_from_engine(engine_page_dom).reload
            expect(dom).to be_valid

            expect(dom.transitions).to be_any
            dom.transitions.each do |transition|
                expect(transition).to be_kind_of IssuePageDomTransition
                expect(transition).to be_valid
            end

            expect(dom.data_flow_sinks).to be_any
            dom.data_flow_sinks.each do |sink|
                expect(sink).to be_kind_of IssuePageDomDataFlowSink
                expect(sink).to be_valid
            end

            expect(dom.execution_flow_sinks).to be_any
            dom.execution_flow_sinks.each do |sink|
                expect(sink).to be_kind_of IssuePageDomExecutionFlowSink
                expect(sink).to be_valid
            end
        end
    end

end
