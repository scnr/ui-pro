require 'spec_helper'

describe 'ProfileRpcHelpers' do
    subject { FactoryGirl.create :site_profile, site: site }
    let(:other) { FactoryGirl.create :site_profile, site: site }
    let(:site) { FactoryGirl.create :site }

    describe '#to_scanner_options' do
        before :each do
            SCNR::Engine::Options.reset
        end

        let(:rpc_options) { subject.to_scanner_options }

        it 'returns RPC options' do
            expect(SCNR::Engine::Options.hash_to_rpc_data( rpc_options )).to eq SCNR::Engine::Options.update( rpc_options ).to_rpc_data
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
    end
end
