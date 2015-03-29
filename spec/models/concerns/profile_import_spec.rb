require 'spec_helper'

describe ProfileImport do
    subject { FactoryGirl.create :profile, user: user }
    let(:other) { FactoryGirl.create :profile, user: user }
    let(:user) { FactoryGirl.create :user }

    describe '.import' do
        let(:file) do
            file = Tempfile.new( Profile.to_s )

            serialized = (serializer == :afr ? subject.to_rpc_options.to_yaml :
                subject.export( serializer ))

            file.write serialized
            file.rewind

            allow(file).to receive(:original_filename) do
                File.basename( file.path )
            end

            file
        end
        let(:imported) { Profile.import( file ) }

        context 'when no #name has been provided' do
            before { subject.name = nil }
            let(:serializer) { YAML }

            it 'uses the filename' do
                expect(imported.name).to eq file.original_filename
            end
        end

        context 'when no #description has been provided' do
            before { subject.description = nil }
            let(:serializer) { YAML }

            it 'sets one including the filename' do
                expect(imported.description).to include file.original_filename
            end
        end

        context 'when the file format is' do
            context 'YAML' do
                let(:serializer) { YAML }

                it 'loads it' do
                    expect(imported.name).to eq subject.name
                    expect(imported.description).to eq subject.description
                    expect(imported.to_rpc_options).to eq subject.to_rpc_options
                end
            end

            context 'JSON' do
                let(:serializer) { JSON }

                it 'loads it' do
                    expect(imported.name).to eq subject.name
                    expect(imported.description).to eq subject.description
                    expect(imported.to_rpc_options).to eq subject.to_rpc_options
                end
            end

            context 'AFR' do
                let(:serializer) { :afr }

                it 'loads it' do
                    expect(imported.name).to eq File.basename( file.path )
                    expect(imported.description).to start_with 'Imported from'
                    expect(imported.to_rpc_options).to eq subject.to_rpc_options
                end
            end
        end
    end

end
