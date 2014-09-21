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
        let(:url) { 'http://test.com/stuff' }
        let(:http_method) { 'get' }
        let(:parameters) { { 'p1' => 'p2' } }
        let(:body) { { 'b1' => 'b2' } }
        let(:headers) do
            {
                'User-Agent' => 'Arachni/v1.0',
                'From'       => 'tasos.laskos@test.com'
            }
        end

        let(:arachni_request) do
            Arachni::HTTP::Request.new(
                url:        url,
                method:     http_method,
                parameters: parameters,
                body:       body,
                headers:    headers
            )
        end

        it "creates a #{described_class} from #{Arachni::HTTP::Request}" do
            request = described_class.create_from_arachni( arachni_request )

            expect(request.url).to eq arachni_request.url
            expect(request.http_method).to eq arachni_request.method.to_s.upcase
            expect(request.parameters).to eq arachni_request.parameters
            expect(request.body).to eq arachni_request.effective_body
            expect(request.headers).to eq arachni_request.headers
            expect(request.raw).to eq arachni_request.to_s
        end
    end

end
