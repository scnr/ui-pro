require 'spec_helper'

describe HttpResponse do
    subject { FactoryGirl.create :http_response }

    expect_it { to belong_to :responsable }

    describe '#headers' do
        it 'is a Hash' do
            expect( subject.headers ).to be_kind_of Hash
        end
    end

    describe '.create_from_arachni' do
        let(:url) { 'http://test.com/stuff' }
        let(:code) { 200 }
        let(:time) { 0.012 }
        let(:ip_address) { '127.0.0.1' }
        let(:return_code) { 'ok' }
        let(:return_message) { 'No error' }
        let(:body) { '<html>stuff' }
        let(:headers) do
            {
                'User-Agent' => 'Arachni/v1.0',
                'From'       => 'tasos.laskos@test.com'
            }
        end

        let(:arachni_response) do
            Arachni::HTTP::Response.new(
                url:            url,
                code:           code,
                time:           time,
                ip_address:     ip_address,
                return_code:    return_code,
                return_message: return_message,
                body:           body,
                headers:        headers
            )
        end

        it "creates a #{described_class} from #{Arachni::HTTP::Response}" do
            response = described_class.create_from_arachni( arachni_response )

            expect(response.url).to eq arachni_response.url
            expect(response.code).to eq arachni_response.code
            expect(response.ip_address).to eq arachni_response.ip_address
            expect(response.return_code).to eq arachni_response.return_code
            expect(response.return_message).to eq arachni_response.return_message
            expect(response.body).to eq arachni_response.body
            expect(response.headers).to eq arachni_response.headers
            expect(response.raw_headers).to eq arachni_response.headers_string
        end
    end

end
