require 'spec_helper'

describe IssuePageDomTransition do
    expect_it { to belong_to :dom }

    describe '.create_from_arachni' do
        let(:arachni_transition) do
            Factory[:transition]
        end

        it "creates a #{described_class} from #{Arachni::Page::DOM::Transition}" do
            frame = described_class.create_from_arachni( arachni_transition ).reload
            expect(frame).to be_valid

            expect(frame.element).to eq arachni_transition.element.to_s
            expect(frame.event).to eq arachni_transition.event.to_s
            expect(frame.time).to eq arachni_transition.time
        end
    end

end
