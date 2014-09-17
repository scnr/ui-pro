require 'spec_helper'

describe Profile do
    subject { FactoryGirl.create :profile, user: user }
    let(:user) { FactoryGirl.create :user }

    expect_it { to belong_to :user }
    expect_it { to have_many :scans }

    describe :validations do
        describe '#name' do
            it 'is required' do
                subject.name = nil

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :name
            end

            it 'is unique for each user' do
                profile = FactoryGirl.build(
                    :profile,
                    name: subject.name,
                    user: user
                )

                expect(profile.save).to be_falsey
                expect(profile.errors).to include :name

                profile = FactoryGirl.build(
                    :profile,
                    name: subject.name,
                    user: FactoryGirl.create( :user, email: 'ff@ff.ff' )
                )

                expect(profile.save).to be_truthy
            end
        end

        describe '#description' do
            it 'is required' do
                subject.description = nil

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :description
            end

            it 'does not permit HTML' do
                subject.description = 'test'
                expect(subject.save).to be_truthy

                subject.description = '<b>test<b/>'
                expect(subject.save).to be_falsey
                expect(subject.errors).to include :description
            end
        end

        describe '#scope_redundant_path_patterns' do
            it 'does not allow 0 counters' do
                subject.scope_redundant_path_patterns = {
                    'stuff' => 1
                }

                expect(subject.save).to be_truthy

                subject.scope_redundant_path_patterns = {
                    'stuff' => 0
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :scope_redundant_path_patterns
            end
        end

        describe '#http_cookies' do
            it 'does not allow empty names' do
                subject.http_cookies = {
                    'name' => 'value'
                }

                expect(subject.save).to be_truthy

                subject.http_cookies = {
                    '' => 'test'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :http_cookies

                subject.http_cookies = {
                    ' ' => 'test'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :http_cookies
            end
        end

        describe '#http_request_headers' do
            it 'does not allow empty names' do
                subject.http_request_headers = {
                    'name' => 'value'
                }

                expect(subject.save).to be_truthy

                subject.http_request_headers = {
                    '' => 'test'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :http_request_headers

                subject.http_request_headers = {
                    ' ' => 'test'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :http_request_headers
            end
        end

        describe '#audit_link_templates' do
            it 'must have named captures' do
                subject.audit_link_templates = 'vdvdv'

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :audit_link_templates

                subject.audit_link_templates = 'input1/(?<input1>\w+)/input2/(?<input2>\w+)'
                expect(subject.save).to be_truthy
            end
        end

        describe '#scope_url_rewrites' do
            it 'must not have empty substitutions' do
                subject.scope_url_rewrites = {
                    'articles\/[\w-]+\/(\d+)' => ''
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :scope_url_rewrites

                subject.scope_url_rewrites = {
                    'articles\/[\w-]+\/(\d+)' => ' '
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :scope_url_rewrites

                subject.scope_url_rewrites = {
                    'articles\/[\w-]+\/(\d+)' => 'articles.php?id=\1'
                }
                expect(subject.save).to be_truthy
            end
        end

        describe '#checks' do
            context 'when a check does not exist' do
                it 'is invalid' do
                    subject.checks = ['stuff']

                    expect(subject.save).to be_falsey
                    expect(subject.errors).to include :checks

                    subject.checks = ['xss']
                    expect(subject.save).to be_truthy
                end
            end
        end

        describe '#platforms' do
            context 'when a platform does not exist' do
                it 'is invalid' do
                    subject.platforms = ['stuff']

                    expect(subject.save).to be_falsey
                    expect(subject.errors).to include :platforms

                    subject.platforms = ['linux']
                    expect(subject.save).to be_truthy
                end
            end
        end

        describe 'session check' do
            before do
                subject.session_check_url     = nil
                subject.session_check_pattern = nil
            end

            context 'when it has a #session_check_url' do
                context 'but not a #session_check_pattern' do
                    it 'is invalid' do
                        subject.session_check_url = 'http://test.com'

                        expect(subject.save).to be_falsey
                        expect(subject.errors).to include :session_check_pattern
                    end
                end
            end

            context 'when it has a #session_check_pattern' do
                context 'but not a #session_check_url' do
                    it 'is invalid' do
                        subject.session_check_pattern = 'stuff'

                        expect(subject.save).to be_falsey
                        expect(subject.errors).to include :session_check_url
                    end
                end
            end

            context 'when #session_check_url is not a valid absolute URL' do
                it 'should be invalid' do
                    subject.session_check_url     = 'stuff-url'
                    subject.session_check_pattern = 'stuff'

                    expect(subject.save).to be_falsey
                    expect(subject.errors).to include :session_check_url
                end
            end

            context 'when it has a valid #session_check_url' do
                context 'and a #session_check_pattern' do
                    it 'is valid' do
                        subject.session_check_url     = 'http://test.com/stuff/'
                        subject.session_check_pattern = 'stuff'

                        expect(subject.save).to be_truthy
                    end
                end
            end
        end
    end

    %w(http_cookies http_request_headers scope_redundant_path_patterns
        scope_url_rewrites input_values).each do |attr|

        describe "#{attr}" do
            it 'is a Hash' do
                expect(subject.send(attr)).to be_kind_of Hash
            end
        end
    end

    %w(scope_exclude_path_patterns scope_exclude_content_patterns
        scope_include_path_patterns scope_extend_paths scope_restrict_paths
        audit_exclude_vector_patterns audit_include_vector_patterns
        audit_link_templates checks platforms).each do |attr|

        describe "#{attr}" do
            it 'is a Array' do
                expect(subject.send(attr)).to be_kind_of Array
            end
        end
    end

    describe '#to_s' do
        it 'returns #name' do
            expect(subject.to_s).to eq subject.name
        end
    end

    describe '#checks' do
        context 'when contains empty strings' do
            it 'removes them' do
                subject.checks = ['', 'xss']

                expect(subject.save).to be_truthy
                expect(subject.checks).to eq ['xss']
            end
        end
    end

    describe '#platforms' do
        context 'when contains empty strings' do
            it 'removes them' do
                subject.platforms = ['', 'linux']

                expect(subject.save).to be_truthy
                expect(subject.platforms).to eq ['linux']
            end
        end
    end

    describe '#to_rpc_options' do
        before :each do
            Arachni::Options.reset
        end

        let(:rpc_options) { subject.to_rpc_options }
        let(:flat_rpc_options) { described_class.flatten rpc_options }

        it 'returns RPC options' do
            expect(Arachni::Options.hash_to_rpc_data( rpc_options )).to eq Arachni::Options.update( rpc_options ).to_rpc_data
        end
    end

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

    describe '#checks_with_info' do
        it 'returns info about the #checks' do
            expect(subject.checks_with_info.values).to eq subject.checks.map { |n| FrameworkHelper.checks[n] }
        end
    end

    describe '.import' do
        let(:file) do
            file = Tempfile.new( described_class.to_s )
            file.write subject.export( serializer )
            file.rewind

            allow(file).to receive(:original_filename) do
                File.basename( file.path )
            end

            file
        end
        let(:imported) { described_class.import( file ) }

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
            context YAML do
                let(:serializer) { YAML }

                it 'loads it' do
                    expect(imported.name).to eq subject.name
                    expect(imported.description).to eq subject.description
                    expect(imported.to_rpc_options).to eq subject.to_rpc_options
                end
            end

            context JSON do
                let(:serializer) { JSON }

                it 'loads it' do
                    expect(imported.name).to eq subject.name
                    expect(imported.description).to eq subject.description
                    expect(imported.to_rpc_options).to eq subject.to_rpc_options
                end
            end
        end
    end
end
