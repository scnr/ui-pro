require 'spec_helper'

describe GlobalProfile do

    subject { FactoryGirl.create :global_profile }

    describe '#plugins' do
        it 'is a Hash' do
            expect(subject.plugins).to be_kind_of Hash
        end
    end

    describe '.to_rpc_options' do
        before :each do
            subject
            Arachni::Options.reset
        end

        let(:rpc_options) { described_class.to_rpc_options }
        let(:flat_rpc_options) { described_class.flatten rpc_options }

        it 'returns RPC options' do
            expect(Arachni::Options.hash_to_rpc_data( rpc_options )).to eq Arachni::Options.update( rpc_options ).to_rpc_data
        end
    end
end
