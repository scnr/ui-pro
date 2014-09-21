require 'spec_helper'

describe Vector do
    subject { FactoryGirl.create :vector }

    expect_it { to belong_to :with_vector }

    describe '#default_inputs' do
        it 'is a Hash' do
            expect( subject.default_inputs ).to be_kind_of Hash
        end
    end

    describe '#inputs' do
        it 'is a Hash' do
            expect( subject.inputs ).to be_kind_of Hash
        end
    end

    describe '#http_method=' do
        it 'converts the method to uppercase' do
            subject.http_method = :post
            expect( subject.http_method ).to eq 'POST'
        end
    end
end
