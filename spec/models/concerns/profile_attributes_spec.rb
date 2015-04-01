require 'spec_helper'

describe ProfileAttributes do
    subject { FactoryGirl.create :profile, user: user }
    let(:other) { FactoryGirl.create :profile, user: user }
    let(:user) { FactoryGirl.create :user }

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

            it 'does not allow invalid patterns' do
                subject.scope_redundant_path_patterns = {
                    '(stuff' => 2
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :scope_redundant_path_patterns
            end
        end

        describe '#input_values' do
            it 'does not allow empty patterns' do
                subject.input_values = {
                    '' => 'blah'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :input_values
            end

            it 'does not allow invalid patterns' do
                subject.input_values = {
                    '(stuff' => '2'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :input_values
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

            it 'does not allow invalid patterns' do
                subject.audit_link_templates = '(vdvdv'

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :audit_link_templates
            end
        end

        describe '#scope_url_rewrites' do
            it 'sets rewrite rules' do
                subject.scope_url_rewrites = {
                    'articles\/[\w-]+\/(\d+)' => 'articles.php?id=\1'
                }
                expect(subject.save).to be_truthy
            end

            it 'must not have empty pattern' do
                subject.scope_url_rewrites = {
                    '' => 'articles.php?id=\1'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :scope_url_rewrites

                subject.scope_url_rewrites = {
                    ' ' => 'articles.php?id=\1'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :scope_url_rewrites
            end

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
            end

            it 'must have substitution with substitutions' do
                subject.scope_url_rewrites = {
                    'articles\/[\w-]+\/(\d+)' => 'stuff'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :scope_url_rewrites
            end

            it 'does not allow invalid patterns' do
                subject.scope_url_rewrites = {
                    '(articles\/[\w-]+\/(\d+)' => 'stuff'
                }

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :scope_url_rewrites
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

            context 'when #session_check_pattern is invalid' do
                it 'is invalid' do
                    subject.session_check_url = 'http://test.com'
                    subject.session_check_pattern = '(stuff'

                    expect(subject.save).to be_falsey
                    expect(subject.errors).to include :session_check_pattern
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

    describe '#checks_with_info' do
        it 'returns info about the #checks' do
            expect(subject.checks_with_info.values).to eq subject.checks.map { |n| FrameworkHelper.checks[n] }
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

    %w(http_cookies http_request_headers scope_redundant_path_patterns
        scope_url_rewrites input_values).each do |attr|

        describe "#{attr}" do
            it 'is a Hash' do
                expect(subject.send(attr)).to be_kind_of Hash
            end
        end
    end

    %w(scope_extend_paths scope_restrict_paths audit_link_templates checks
        platforms).each do |attr|

        describe "#{attr}" do
            it 'is a Array' do
                expect(subject.send(attr)).to be_kind_of Array
            end
        end
    end

    %w(scope_exclude_path_patterns scope_exclude_content_patterns
        scope_include_path_patterns audit_exclude_vector_patterns
        audit_include_vector_patterns).each do |attr|

        describe "#{attr}" do
            it 'is a Array' do
                expect(subject.send(attr)).to be_kind_of Array
            end

            it 'does not allow invalid patterns' do
                subject.send( "#{attr}=", ['(stuff'] )

                expect(subject.save).to be_falsey
                expect(subject.errors).to include attr.to_sym
            end
        end
    end
end
