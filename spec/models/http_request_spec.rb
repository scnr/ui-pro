require 'spec_helper'

describe HttpRequest do
    subject { FactoryGirl.create :http_request }

    expect_it { to belong_to :requestable }

    describe '#headers' do
        it 'is a Hash' do
            expect( subject.headers ).to be_kind_of Hash
        end
    end

    describe '#parameters' do
        it 'is a Hash' do
            expect( subject.parameters ).to be_kind_of Hash
        end
    end

    describe '#http_method=' do
        it 'converts the method to uppercase' do
            subject.http_method = :post
            expect( subject.http_method ).to eq 'POST'
        end
    end

end
