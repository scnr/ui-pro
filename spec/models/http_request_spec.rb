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

    describe '.create_from_arachni' do
        let(:arachni_request) do
            Factory[:request]
        end

        it "creates a #{described_class} from #{Arachni::HTTP::Request}" do
            request = described_class.create_from_arachni( arachni_request ).reload
            expect(request).to be_valid

            expect(request.url).to eq arachni_request.url
            expect(request.http_method).to eq arachni_request.method.to_s.upcase
            expect(request.parameters).to eq arachni_request.parameters
            expect(request.body).to eq arachni_request.effective_body
            expect(request.headers).to eq arachni_request.headers
            expect(request.raw).to eq arachni_request.to_s
        end
    end

end
