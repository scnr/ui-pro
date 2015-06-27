require 'rails_helper'

describe SiteRole, type: :model do
    subject { FactoryGirl.create :site_role }
    let(:site){ FactoryGirl.create :site }
    let(:other_site){ FactoryGirl.create :site }

    expect_it { to belong_to :site }
    expect_it { to have_many :scans }
    expect_it { to have_many :revisions }
    expect_it { to validate_presence_of :site }
    expect_it { to validate_presence_of :name }
    expect_it { to validate_presence_of :session_check_url }
    expect_it { to validate_presence_of :session_check_pattern }
    expect_it { to validate_presence_of :scope_exclude_path_patterns }
    expect_it { to validate_presence_of :login_type }

    describe '#name' do
        it 'is unique for each site' do
            data = subject.attributes.merge( name: 'stuff' )
            data.delete 'id'

            expect(site.roles.create( data )).to be_valid

            role = site.roles.create( data )
            expect(role.errors.messages).to include :name
        end
    end

    describe '.guest' do
        it 'returns the Guest role' do
            site = subject.site
            site.roles.delete_all

            guest = FactoryGirl.create( :site_role, site: site, login_type: 'none' )
            FactoryGirl.create( :site_role, site: site )

            expect(described_class.guest).to eq guest
        end
    end

    describe '#guest?' do
        context 'when login_type is' do
            describe 'none' do
                before do
                    subject.login_type = 'none'
                end

                it 'returns true' do
                    expect(subject).to be_guest
                end
            end

            describe 'form' do
                before do
                    subject.login_type = 'form'
                end

                it 'returns false' do
                    expect(subject).to_not be_guest
                end
            end

            describe 'script' do
                before do
                    subject.login_type = 'script'
                end

                it 'returns false' do
                    expect(subject).to_not be_guest
                end
            end
        end
    end

    describe '#login_type' do
        it 'can be form' do
            subject.login_type = 'form'
            expect(subject).to be_valid
        end

        it 'can be script' do
            subject.login_type = 'script'
            expect(subject).to be_valid
        end

        it 'cannot be other' do
            subject.login_type = 'stuff'
            expect(subject).to_not be_valid
        end
    end

    describe '#login_form_url' do
        context 'when #login_type is' do
            describe 'form' do
                before do
                    subject.login_type = 'form'
                end

                it 'is required' do
                    subject.login_form_url = nil
                    subject.save
                    expect(subject.errors.messages).to include :login_form_url

                    subject.login_form_url = subject.site.url
                    expect(subject.save).to be_truthy
                end
            end

            describe 'script' do
                before do
                    subject.login_type = 'script'
                end

                it 'is not required' do
                    subject.login_form_url = nil
                    expect(subject).to be_valid
                end
            end

            describe 'none' do
                before do
                    subject.login_type = 'none'
                end

                it 'is not required' do
                    subject.login_form_url = nil
                    expect(subject).to be_valid
                end
            end
        end
    end

    describe '#login_form_parameters' do
        context 'when #login_type is' do
            describe 'form' do
                before do
                    subject.login_type = 'form'
                end

                it 'is required' do
                    subject.login_form_parameters = {}
                    subject.save
                    expect(subject.errors.messages).to include :login_form_parameters

                    subject.login_form_parameters = { '1' => '2' }
                    expect(subject.save).to be_truthy
                end
            end

            describe 'script' do
                before do
                    subject.login_type = 'script'
                end

                it 'is not required' do
                    subject.login_form_parameters = nil
                    expect(subject).to be_valid
                end
            end

            describe 'none' do
                before do
                    subject.login_type = 'none'
                end

                it 'is not required' do
                    subject.login_form_parameters = nil
                    expect(subject).to be_valid
                end
            end
        end
    end

    describe '#login_script_code' do
        context 'when #login_type is' do
            describe 'script' do
                before do
                    subject.login_type = 'script'
                end

                it 'is required' do
                    subject.login_script_code = nil
                    subject.save
                    expect(subject.errors.messages).to include :login_script_code

                    subject.login_script_code = 'stuff'
                    expect(subject.save).to be_truthy
                end

                it 'has to be syntactically valid' do
                    subject.login_script_code = 'puts "'
                    subject.save
                    expect(subject.errors.messages).to include :login_script_code

                    subject.login_script_code = 'puts "stuff"'
                    expect(subject.save).to be_truthy
                end
            end

            describe 'form' do
                before do
                    subject.login_type = 'form'
                end

                it 'is not required' do
                    subject.login_script_code = nil
                    expect(subject).to be_valid
                end

                it 'does not have to be syntactically valid' do
                    subject.login_script_code = 'puts "'
                    expect(subject).to be_valid
                end
            end

            describe 'none' do
                before do
                    subject.login_type = 'none'
                end

                it 'is not required' do
                    subject.login_script_code = nil
                    expect(subject).to be_valid
                end

                it 'does not have to be syntactically valid' do
                    subject.login_script_code = 'puts "'
                    expect(subject).to be_valid
                end
            end
        end
    end

    context '#session_check_url' do
        context 'when invalid' do
            it 'is invalid' do
                subject.session_check_url     = ''
                subject.session_check_pattern = 'stuff'

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :session_check_url
            end
        end

        context 'when #login_type is' do
            describe 'none' do
                before do
                    subject.login_type = 'none'
                end

                it 'is not required' do
                    subject.session_check_url = nil
                    expect(subject.reload).to be_valid
                end
            end
        end
    end

    context '#session_check_pattern' do
        context 'when invalid' do
            it 'is invalid' do
                subject.session_check_url     = 'http://test.com'
                subject.session_check_pattern = '(stuff'

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :session_check_pattern
            end
        end

        context 'when #login_type is' do
            describe 'none' do
                before do
                    subject.login_type = 'none'
                end

                it 'is not required' do
                    subject.session_check_pattern = nil
                    expect(subject.reload).to be_valid
                end
            end
        end
    end

    describe '#login_script_code_tempfile' do
        it 'returns the location of a file containing #login_script_code' do
            expect(IO.read(subject.login_script_code_tempfile)).to eq subject.login_script_code
        end
    end

    describe '#login_script_code_error_line' do
        before do
            subject.login_type = 'script'
        end

        context 'when there is a syntax error' do
            it 'returns the number of the line' do
                subject.login_script_code =<<EORUBY
                puts 1
                e = 1)

                def foo
                end
EORUBY
                subject.save
                expect(subject.login_script_code_error_line).to eq 2
            end
        end

        context 'when there is no syntax error' do
            it 'returns nil' do
                subject.login_script_code =<<EORUBY
                puts 1
                e = 1+2

                def foo
                end
EORUBY
                subject.save
                expect(subject.login_script_code_error_line).to be_nil
            end
        end
    end

    describe '#to_rpc_options' do
        let(:rpc_options) do
            options = subject.to_rpc_options
            options.delete 'plugins'
            options
        end

        it 'includes Arachni options' do
            expect(rpc_options).to eq({
                'session' => {
                    'check_url'     => 'http://stuff/',
                    'check_pattern' => 'logout.php'
                },
                'scope' => {
                    'exclude_path_patterns' => [
                        'site-role-exclude-that',
                        'site-role-exclude-that-too'
                    ]
                }
            })
        end

        context 'when #login_type is' do
            let(:rpc_options) do
                subject.to_rpc_options['plugins']
            end

            describe 'script' do
                before do
                    subject.login_type = 'script'
                end

                it 'configures the login_script plugin' do
                    expect(rpc_options).to eq ({
                        'login_script' => {
                            'script' => subject.login_script_code_tempfile
                        }
                    })
                end
            end

            describe 'form' do
                before do
                    subject.login_type = 'form'
                end

                it 'configures the autologin plugin' do
                    expect(rpc_options).to eq ({
                        'autologin' => {
                            'url'        => subject.site.url,
                            'parameters' => 'username=joe&password=secret',
                            'check'      => 'logout.php'
                        }
                    })
                end
            end
        end
    end

    describe '#to_s' do
        it 'returns the name' do
            expect(subject.to_s.object_id).to eq subject.name.object_id
        end
    end
end
