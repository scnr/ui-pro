require 'spec_helper'

describe IssuePageDomStackFrame do
    expect_it { to belong_to :with_dom_stack_frame }
    expect_it { to have_one :function }

    describe '.create_from_arachni' do
        let(:arachni_stackframe) do
            Factory[:frame]
        end

        it "creates a #{described_class} from #{Arachni::Browser::Javascript::TaintTracer::Frame}" do
            frame = described_class.create_from_arachni( arachni_stackframe ).reload
            expect(frame).to be_valid

            expect(frame.url).to eq arachni_stackframe.url
            expect(frame.line).to eq arachni_stackframe.line

            [:name, :source, :arguments].each do |attr|
                expect(frame.function.send(attr)).to eq arachni_stackframe.function.send(attr)
            end
        end
    end

end
