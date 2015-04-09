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

        describe '#plugins' do
            context 'when a plugin does not exist' do
                it 'is invalid' do
                    subject.plugins = { 'stuff' => {} }

                    expect(subject.save).to be_falsey
                    expect(subject.errors).to include :plugins
                end
            end

            context 'when given invalid options' do
                it 'is invalid' do
                    subject.plugins = { 'proxy' => {
                        'port' => 'ddd'
                    }}

                    expect(subject.save).to be_falsey
                    expect(subject.errors).to include :plugins

                    expect(subject.errors.messages[:plugins].first).to include 'Invalid options for component: proxy'
                end
            end

            context 'when given missing options' do
                it 'is invalid' do
                    subject.plugins = { 'form_dicattack' => {} }

                    expect(subject.save).to be_falsey
                    expect(subject.errors).to include :plugins

                    expect(subject.errors.messages[:plugins].first).to include 'Missing value: username_list'
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

    %w(scope_extend_paths scope_restrict_paths checks).each do |attr|
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
