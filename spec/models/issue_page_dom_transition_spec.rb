require 'spec_helper'

describe IssuePageDomTransition do
    expect_it { to belong_to :dom }

    describe '.create_from_arachni' do
        let(:arachni_transition) do
            Factory[:transition]
        end

        it "creates a #{described_class} from #{Arachni::Page::DOM::Transition}" do
            transition = described_class.create_from_arachni( arachni_transition ).reload
            expect(transition).to be_valid

            expect(transition.element).to eq arachni_transition.element.to_s
            expect(transition.event).to eq arachni_transition.event
            expect(transition.time).to eq arachni_transition.time
        end
    end

end
