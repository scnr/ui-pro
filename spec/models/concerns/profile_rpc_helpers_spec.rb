require 'spec_helper'

describe ProfileRpcHelpers do
    subject { FactoryGirl.create :profile, user: user }
    let(:other) { FactoryGirl.create :profile, user: user }
    let(:user) { FactoryGirl.create :user }

    describe '#to_rpc_options' do
        before :each do
            Arachni::Options.reset
        end

        let(:rpc_options) { subject.to_rpc_options }

        it 'returns RPC options' do
            expect(Arachni::Options.hash_to_rpc_data( rpc_options )).to eq Arachni::Options.update( rpc_options ).to_rpc_data
        end

        it 'includes default plugins' do
            DEFAULT_PLUGINS.each do |name|
                expect(rpc_options['plugins'][name.to_s]).to eq Hash.new
            end
        end
    end
end
