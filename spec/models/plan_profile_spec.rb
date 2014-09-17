require 'spec_helper'

describe PlanProfile do
    subject { FactoryGirl.create :plan_profile }

    expect_it { to belong_to :plan }

    describe '#to_rpc_options' do
        before :each do
            Arachni::Options.reset
        end

        let(:rpc_options) { subject.to_rpc_options }
        let(:flat_rpc_options) { described_class.flatten rpc_options }

        it 'returns RPC options' do
            expect(Arachni::Options.hash_to_rpc_data( rpc_options )).to eq Arachni::Options.update( rpc_options ).to_rpc_data
        end
    end
end
