require 'spec_helper'

describe ProfileRpcHelpers do
    subject { FactoryGirl.create :profile, user: user }
    let(:other) { FactoryGirl.create :profile, user: user }
    let(:user) { FactoryGirl.create :user }

    describe '#to_rpc_options' do
        before :each do
            Arachni::Options.reset
        end

        let(:rpc_options) { subject.to_rpc_options }

        it 'returns RPC options' do
            expect(Arachni::Options.hash_to_rpc_data( rpc_options )).to eq Arachni::Options.update( rpc_options ).to_rpc_data
        end

        it 'includes default plugins' do
            DEFAULT_PLUGINS.each do |name|
                expect(rpc_options['plugins'][name.to_s]).to eq Hash.new
            end
        end

        context 'http' do
            subject { FactoryGirl.create :site_profile }

            context 'when authentication_username is' do
                context 'empty' do
                    before do
                        subject.http_authentication_username = ''
                    end

                    it 'does not include it' do
                        expect(rpc_options['http']).to_not include 'authentication_username'
                    end
                end

                context 'nil' do
                    before do
                        subject.http_authentication_username = nil
                    end

                    it 'does not include it' do
                        expect(rpc_options['http']).to_not include 'authentication_username'
                    end
                end

                context 'not blank' do
                    before do
                        subject.http_authentication_username = 'stuff'
                    end

                    it 'does not include it' do
                        expect(rpc_options['http']['authentication_username']).to eq 'stuff'
                    end
                end
            end

            context 'when authentication_password is' do
                context 'empty' do
                    before do
                        subject.http_authentication_password = ''
                    end

                    it 'does not include it' do
                        expect(rpc_options['http']).to_not include 'authentication_password'
                    end
                end

                context 'nil' do
                    before do
                        subject.http_authentication_password = nil
                    end

                    it 'does not include it' do
                        expect(rpc_options['http']).to_not include 'authentication_password'
                    end
                end

                context 'not blank' do
                    before do
                        subject.http_authentication_password = 'stuff'
                    end

                    it 'does not include it' do
                        expect(rpc_options['http']['authentication_password']).to eq 'stuff'
                    end
                end
            end
        end
    end
end
