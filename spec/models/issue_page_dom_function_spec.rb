require 'spec_helper'

describe IssuePageDomFunction do
    subject { FactoryGirl.create :issue_page_dom_function }

    expect_it { to belong_to :with_dom_function }

    describe '#arguments' do
        it 'is an Array' do
            expect( subject.arguments ).to be_kind_of Array
        end
    end

    describe '.create_from_arachni' do
        let(:source) do
            "function decodeURI() {
                 [native code]
             }"
        end
        let(:arguments) do
            ["#%7Cinput%7Cdefault%3Csome_dangerous_input_c19b39d05da8ac6c4a1643ad7b2ca89b/%3E"]
        end
        let(:name) { 'name' }

        let(:arachni_function) do
            Arachni::Browser::Javascript::TaintTracer::Frame::CalledFunction.new(
                name:      name,
                source:    source,
                arguments: arguments
            )
        end

        it "creates a #{described_class} from #{Arachni::Browser::Javascript::TaintTracer::Frame::CalledFunction}" do
            function = described_class.create_from_arachni( arachni_function )

            expect(function.name).to eq arachni_function.name
            expect(function.source).to eq arachni_function.source
            expect(function.arguments).to eq arachni_function.arguments
        end
    end

end
