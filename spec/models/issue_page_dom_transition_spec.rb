require 'spec_helper'

describe IssuePageDomTransition do
    expect_it { to belong_to :dom }

    describe '.create_from_engine' do
        let(:engine_transition) do
            Factory[:transition]
        end

        it "creates a #{described_class} from #{SCNR::Engine::Page::DOM::Transition}" do
            transition = described_class.create_from_engine(engine_transition)

            expect(transition.element).to eq engine_transition.element.to_s
            expect(transition.event).to eq engine_transition.event
            expect(transition.time).to eq engine_transition.time
        end
    end

end
