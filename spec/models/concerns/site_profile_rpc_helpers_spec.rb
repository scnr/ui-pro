require 'spec_helper'

describe ProfileRpcHelpers do
    subject { FactoryGirl.create :site_profile, site: site }
    let(:other) { FactoryGirl.create :site_profile, site: site }
    let(:site) { FactoryGirl.create :site }

    describe '#to_rpc_options' do
        before :each do
            Arachni::Options.reset
        end

        let(:rpc_options) { subject.to_rpc_options }

        it 'returns RPC options' do
            expect(Arachni::Options.hash_to_rpc_data( rpc_options )).to eq Arachni::Options.update( rpc_options ).to_rpc_data
        end

        context 'when there are #scope_template_path_patterns' do
            it 'includes the as redundant_path_patterns'do
                subject.scope_template_path_patterns = [ 'template1', 'template2' ]

                expect(rpc_options['scope']['redundant_path_patterns']).to eq({
                    'template1' => described_class::TEMPLATE_PATH_PATTERN_COUNTER,
                    'template2' => described_class::TEMPLATE_PATH_PATTERN_COUNTER
                })
            end
        end

        context 'when there are no #scope_template_path_patterns' do
            it 'includes the as redundant_path_patterns'do
                subject.scope_template_path_patterns = []

                expect(rpc_options['scope']).to_not include 'redundant_path_patterns'
            end
        end
    end
end
