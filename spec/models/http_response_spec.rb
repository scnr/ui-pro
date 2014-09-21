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
        let(:arachni_response) do
            Factory[:response]
        end

        it "creates a #{described_class} from #{Arachni::HTTP::Response}" do
            response = described_class.create_from_arachni( arachni_response ).reload
            expect(response).to be_valid

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
