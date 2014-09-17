require 'spec_helper'

describe DefaultProfile do

    subject { FactoryGirl.create :default_profile }

    describe '#to_s' do
        it 'returns #name' do
            expect(subject.to_s).to eq subject.name
        end
    end

    describe '#plugins' do
        it 'is a Hash' do
            expect(subject.plugins).to be_kind_of Hash
        end
    end

    describe '#to_rpc_options' do
        before :each do
            Arachni::Options.reset
        end

        let(:rpc_options) { subject.to_rpc_options }
        let(:flat_rpc_options) { described_class.flatten rpc_options }

        it 'includes user RPC options' do
            expect(Arachni::Options.hash_to_rpc_data( rpc_options )).to eq Arachni::Options.update( rpc_options ).to_rpc_data
        end
    end
end
