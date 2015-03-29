require 'spec_helper'

describe ProfileExport do
    subject { FactoryGirl.create :profile, user: user }
    let(:other) { FactoryGirl.create :profile, user: user }
    let(:user) { FactoryGirl.create :user }

    describe '#export' do
        context 'when format is' do
            context YAML do
                it 'returns the #to_rpc_options as YAML' do
                    yaml = YAML.load( subject.export( YAML ) )

                    %w(name description).each do |k|
                        expect(subject.send(k)).to eq yaml.delete(k)
                    end

                    expect(subject.to_rpc_options).to eq yaml
                end
            end

            context JSON do
                it 'returns the #to_rpc_options as YAML' do
                    yaml = JSON.load( subject.export( JSON ) )

                    %w(name description).each do |k|
                        expect(subject.send(k)).to eq yaml.delete(k)
                    end

                    expect(subject.to_rpc_options).to eq yaml
                end
            end

            context 'default' do
                it 'defaults to YAML' do
                    expect(subject.export).to eq subject.export( YAML )
                end
            end
        end
    end

end
