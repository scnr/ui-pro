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

    describe '.create_from_arachni' do
        [Arachni::Element::Link, Arachni::Element::Link::DOM,
         Arachni::Element::Form, Arachni::Element::Form::DOM,
         Arachni::Element::LinkTemplate, Arachni::Element::LinkTemplate::DOM,
         Arachni::Element::JSON, Arachni::Element::XML
        ].each do |klass|
            it "creates a #{described_class} from #{klass}" do
                arachni_vector = Factory[klass.type]
                vector = described_class.create_from_arachni( arachni_vector ).reload
                expect(vector).to be_valid

                expect(vector.action).to eq arachni_vector.action
                expect(vector.seed).to eq arachni_vector.seed
                expect(vector.affected_input_name).to eq arachni_vector.affected_input_name
                expect(vector.inputs).to eq arachni_vector.inputs
                expect(vector.default_inputs).to eq arachni_vector.default_inputs
                expect(vector.source).to eq arachni_vector.source
                expect(vector.http_method).to eq arachni_vector.http_method.to_s.upcase
                expect(vector.arachni_class).to eq arachni_vector.class.to_s
                expect(vector.kind).to eq arachni_vector.class.type.to_s
            end
        end

        [ Arachni::Element::Cookie, Arachni::Element::Cookie::DOM,
         Arachni::Element::Header ].each do |klass|
            it "creates a #{described_class} from #{klass}" do
                arachni_vector = Factory[klass.type]
                vector = described_class.create_from_arachni( arachni_vector ).reload
                expect(vector).to be_valid

                expect(vector.action).to eq arachni_vector.action
                expect(vector.seed).to eq arachni_vector.seed
                expect(vector.affected_input_name).to eq arachni_vector.affected_input_name
                expect(vector.inputs).to eq arachni_vector.inputs
                expect(vector.default_inputs).to eq arachni_vector.default_inputs
                expect(vector.http_method).to eq arachni_vector.http_method.to_s.upcase
                expect(vector.arachni_class).to eq arachni_vector.class.to_s
                expect(vector.kind).to eq arachni_vector.class.type.to_s
            end
        end

        it "creates a #{described_class} from #{Arachni::Element::GenericDOM}" do
            arachni_vector = Factory[Arachni::Element::GenericDOM.type]
            vector = described_class.create_from_arachni( arachni_vector ).reload
            expect(vector).to be_valid

            expect(vector.action).to eq arachni_vector.action
            expect(vector.affected_input_name).to eq arachni_vector.affected_input_name
            expect(vector.arachni_class).to eq arachni_vector.class.to_s
            expect(vector.kind).to eq arachni_vector.class.type.to_s
        end

        [Arachni::Element::Body, Arachni::Element::Server, Arachni::Element::Path].each do |klass|
            it "creates a #{described_class} from #{klass}" do
                arachni_vector = Factory[klass.type]
                vector = described_class.create_from_arachni( arachni_vector ).reload
                expect(vector).to be_valid

                expect(vector.action).to eq arachni_vector.action
                expect(vector.arachni_class).to eq arachni_vector.class.to_s
                expect(vector.kind).to eq arachni_vector.class.type.to_s
            end
        end
    end

end
