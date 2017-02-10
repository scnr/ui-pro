require 'spec_helper'

describe Vector do
    subject { FactoryGirl.create :vector }

    expect_it { to belong_to(:sitemap_entry).counter_cache(true) }

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

    describe '.create_from_engine' do
        [SCNR::Engine::Element::Link, SCNR::Engine::Element::Link::DOM,
         SCNR::Engine::Element::Form, SCNR::Engine::Element::Form::DOM,
         SCNR::Engine::Element::LinkTemplate, SCNR::Engine::Element::LinkTemplate::DOM,
         SCNR::Engine::Element::JSON, SCNR::Engine::Element::XML
        ].each do |klass|
            it "creates a #{described_class} from #{klass}" do
                engine_vector = Factory[klass.type]
                vector = described_class.create_from_engine(engine_vector ).reload
                expect(vector).to be_valid

                expect(vector.action).to eq engine_vector.action
                expect(vector.seed).to eq engine_vector.seed
                expect(vector.affected_input_name).to eq engine_vector.affected_input_name
                expect(vector.inputs).to eq engine_vector.inputs
                expect(vector.default_inputs).to eq engine_vector.default_inputs
                expect(vector.source).to eq engine_vector.source
                expect(vector.http_method).to eq engine_vector.http_method.to_s.upcase
                expect(vector.engine_class).to eq engine_vector.class
                expect(vector.kind).to eq engine_vector.class.type
            end
        end

        [ SCNR::Engine::Element::Cookie, SCNR::Engine::Element::Cookie::DOM,
         SCNR::Engine::Element::Header ].each do |klass|
            it "creates a #{described_class} from #{klass}" do
                engine_vector = Factory[klass.type]
                vector = described_class.create_from_engine(engine_vector ).reload
                expect(vector).to be_valid

                expect(vector.action).to eq engine_vector.action
                expect(vector.seed).to eq engine_vector.seed
                expect(vector.affected_input_name).to eq engine_vector.affected_input_name
                expect(vector.inputs).to eq engine_vector.inputs
                expect(vector.default_inputs).to eq engine_vector.default_inputs
                expect(vector.http_method).to eq engine_vector.http_method.to_s.upcase
                expect(vector.engine_class).to eq engine_vector.class
                expect(vector.kind).to eq engine_vector.class.type
            end
        end

        it "creates a #{described_class} from #{SCNR::Engine::Element::GenericDOM}" do
            engine_vector = Factory[SCNR::Engine::Element::GenericDOM.type]
            vector = described_class.create_from_engine(engine_vector ).reload
            expect(vector).to be_valid

            expect(vector.action).to eq engine_vector.action
            expect(vector.affected_input_name).to eq engine_vector.affected_input_name
            expect(vector.engine_class).to eq engine_vector.class
            expect(vector.kind).to eq engine_vector.class.type
        end

        [SCNR::Engine::Element::Body, SCNR::Engine::Element::Server, SCNR::Engine::Element::Path].each do |klass|
            it "creates a #{described_class} from #{klass}" do
                engine_vector = Factory[klass.type]
                vector = described_class.create_from_engine(engine_vector ).reload
                expect(vector).to be_valid

                expect(vector.action).to eq engine_vector.action
                expect(vector.engine_class).to eq engine_vector.class
                expect(vector.kind).to eq engine_vector.class.type
            end
        end
    end

end
