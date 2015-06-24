require 'spec_helper'

describe Scan do
    subject { FactoryGirl.create :scan, site: site }
    let(:settings){ FactoryGirl.create :setting }
    let(:other_scan) { FactoryGirl.create :scan, site: site }

    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site, user: user }
    let(:other_site) { FactoryGirl.create :site, host: 'ff.dd' }

    expect_it { to belong_to :site }
    expect_it { to belong_to :profile }
    expect_it { to belong_to :user_agent }
    expect_it { to validate_presence_of :user_agent }
    expect_it { to have_one(:schedule).dependent(:destroy).autosave(true) }
    expect_it { to have_many(:revisions).dependent(:destroy) }
    expect_it { to have_many :issues }

    it 'accepts nested attributes for #schedule' do
        subject.update( schedule_attributes: { month_frequency: 10 } )
        expect(subject.schedule.month_frequency).to eq 10

        subject.save

        expect(subject.schedule.month_frequency).to eq 10
    end

    describe 'scopes' do
        let(:scheduled) do
            [
                FactoryGirl.create( :scan,
                                    site: site,
                                    name: 'stuff',
                                    schedule_attributes: {
                                        start_at: Time.now
                                    }
                ),
                FactoryGirl.create( :scan,
                                    site: site,
                                    name: 'stuff2',
                                    schedule_attributes: {
                                        start_at: Time.now
                                    }
                )
            ]
        end

        let(:unscheduled) do
            [
                FactoryGirl.create( :scan, site: site, name: 'stuff3' ),
                FactoryGirl.create( :scan, site: site, name: 'stuff4' )
            ].each { |s| s.schedule = nil; s.save; }
        end

        let(:with_revisions) do
            [
                FactoryGirl.create( :scan,
                                    site: site,
                                    name: 'stuff5',
                                    schedule_attributes: {
                                        start_at: Time.now
                                    }
                ).tap { |s| s.revisions.create },
                FactoryGirl.create( :scan,
                                    site: site,
                                    name: 'stuff6',
                                    schedule_attributes: {
                                        start_at: Time.now
                                    },
                ).tap { |s| s.revisions.create },
            ]
        end

        let(:without_revisions) do
            [
                FactoryGirl.create( :scan, site: site, name: 'stuff7' ),
                FactoryGirl.create( :scan, site: site, name: 'stuff8' )
            ]
        end

        describe 'scheduled' do
            it 'returns scans with #schedule' do
                scheduled
                unscheduled

                expect(described_class.scheduled).to eq scheduled
            end
        end

        describe 'unscheduled' do
            before { described_class.delete_all }

            it "returns scans without #{Scan}#start_at" do
                scheduled
                unscheduled

                expect(described_class.unscheduled).to eq unscheduled
            end
        end

        describe 'with_revisions' do
            it "returns scans with #{Revision}" do
                with_revisions
                without_revisions

                expect(described_class.with_revisions).to eq with_revisions
            end
        end
    end

    describe 'validations' do
        it 'validates the #schedule' do
            subject.build_schedule
            subject.schedule.start_at = 'stuff'

            expect(subject.save).to be_falsey
            expect(subject.errors).to include :schedule
        end

        describe '#name' do
            let(:name) { 'stuff' }

            it 'is required' do
                subject.name = ''

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :name
            end

            context 'for each #site' do
                it 'is unique' do
                    subject.name = name
                    expect(subject.save).to be_truthy

                    other_scan.name = name
                    expect(other_scan.save).to be_falsey

                    expect(other_scan.errors).to include :name

                    # With different sites.

                    subject.name = name
                    expect(subject.save).to be_truthy

                    other_scan.site = other_site
                    other_scan.name = name
                    expect(other_scan.save).to be_truthy
                end
            end
        end

        describe '#profile' do
            let(:profile) { FactoryGirl.create :profile }

            it 'is required' do
                subject.profile = nil

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :profile

                subject.profile = profile

                expect(subject.save).to be_truthy
            end
        end

        describe '#site' do
            let(:site) { FactoryGirl.create :site }

            it 'is required' do
                subject.site = nil

                expect(subject.save).to be_falsey
                expect(subject.errors).to include :site

                subject.site = site

                expect(subject.save).to be_truthy
            end
        end
    end

    describe '#scheduled?' do
        context 'when there is a #schedule' do
            before do
                subject.build_schedule
            end

            it 'returns true' do
                expect(subject).to be_scheduled
            end
        end

        context 'when there is no #schedule' do
            before do
                subject.schedule = nil
            end

            it 'returns false' do
                expect(subject).to_not be_scheduled
            end
        end
    end

    describe '#recurring?' do
        context 'when there is a #schedule' do
            context 'and it is recurring' do
                before do
                    allow(subject.schedule).to receive(:recurring?) { true }
                end

                it 'returns true' do
                    expect(subject).to be_recurring
                end
            end

            context 'and is not recurring' do
                before do
                    allow(subject.schedule).to receive(:recurring?) { false }
                end

                it 'returns false' do
                    expect(subject).to_not be_recurring
                end
            end
        end

        context 'when there is no #schedule' do
            before do
                subject.schedule = nil
            end

            it 'returns false' do
                expect(subject).to_not be_recurring
            end
        end
    end

    describe '#in_progress?' do
        context 'when there is a started but not stopped revision' do
            before do
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now,
                    stopped_at: nil
                )
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now + 1000,
                    stopped_at: Time.now + 2000
                )
            end

            it 'returns true' do
                expect(subject.reload).to be_in_progress
            end
        end

        context 'when there is a started and stopped revision' do
            before do
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now,
                    stopped_at: Time.now + 3000
                )
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now + 1000,
                    stopped_at: Time.now + 2000
                )
            end

            it 'returns false' do
                expect(subject).to_not be_in_progress
            end
        end

        context 'when there is not a started and nor stopped revision' do
            before do
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: nil,
                    stopped_at: nil
                )
            end

            it 'returns false' do
                expect(subject).to_not be_in_progress
            end
        end
    end

    describe '#last_performed_at' do
        context 'when there are stopped revisions' do
            before do
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now,
                    stopped_at: nil
                )
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now + 1000,
                    stopped_at: nil
                )
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now + 2000,
                    stopped_at: Time.now + 3000,
                )
                subject.revisions << last_performed
            end
            let(:last_performed) do
                FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now,
                    stopped_at: Time.now + 4000
                )
            end

            it 'returns the time the last revision was performed' do
                expect(subject.reload.last_performed_at.to_s).to eq last_performed.performed_at.to_s
            end
        end

        context 'when there are no stopped revisions' do
            before do
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now,
                    stopped_at: nil
                )
                subject.revisions << FactoryGirl.create(
                    :revision,
                    scan: subject,
                    started_at: Time.now + 1000,
                    stopped_at: nil
                )
            end

            it 'returns nil' do
                expect(subject.last_performed_at).to be_nil
            end
        end

        context 'when there are no revisions' do
            it 'returns nil' do
                expect(subject.revisions).to_not be_any
                expect(subject.last_performed_at).to be_nil
            end
        end
    end

    describe '#path=' do
        context 'when the path starts with /' do
            it 'just stores it' do
                subject.path = '/stuff'
                expect(subject.path).to eq '/stuff'
            end
        end

        context 'when the path does not start with /' do
            it 'suffixes one' do
                subject.path = 'stuff'
                expect(subject.path).to eq '/stuff'
            end
        end

        context 'when given nil' do
            it 'defaults to /' do
                subject.path = nil
                expect(subject.path).to eq '/'
            end
        end
    end

    describe '#to_s' do
        it 'returns #name' do
            subject.name = 'stuff'
            expect(subject.to_s).to eq 'stuff'
        end
    end

    describe '#url' do
        it 'returns the site URL combined with the #path' do
            subject.path = '/stuff'
            expect(subject.url).to eq "#{site.url}/stuff"
        end
    end

    describe '#rpc_options' do
        before :each do
            settings
            Arachni::Options.reset
        end

        let(:rpc_options) do
            subject.rpc_options.merge( 'authorized_by' => user.email )
        end
        let(:normalized_rpc_options) do
            Arachni::Options.hash_to_rpc_data( rpc_options )
        end

        it 'returns RPC options' do
            expect(normalized_rpc_options).to eq Arachni::Options.update( rpc_options ).to_rpc_data
        end

        it 'merges the profile, site profile, user-agent and global settings' do
            options = subject.profile.to_rpc_options.
                merge( 'authorized_by' => user.email ).
                deep_merge( site.profile.to_rpc_options ).
                deep_merge( subject.user_agent.to_rpc_options ).
                deep_merge( settings.to_rpc_options )

            options['scope'].delete( 'exclude_path_patterns' )
            options['scope'].delete( 'exclude_content_patterns' )

            options['session'] = subject.site_role.to_rpc_options['session']

            expect(rpc_options['scope'].delete( 'exclude_path_patterns' ).sort).to eq(
                (subject.profile.scope_exclude_path_patterns |
                    site.profile.scope_exclude_path_patterns |
                    subject.site_role.scope_exclude_path_patterns).sort
            )

            expect(rpc_options['scope'].delete( 'exclude_content_patterns' ).sort).to eq(
                (subject.profile.scope_exclude_content_patterns |
                    site.profile.scope_exclude_content_patterns).sort
            )

            options['url'] = subject.url
            options['plugins']['autologin'] = {
                'url'        => subject.site_role.site.url,
                'parameters' => 'username=joe&password=secret',
                'check'      => 'logout.php'
            }

            expect(options).to eq rpc_options
        end
    end

    describe '#scheduled?' do
        context 'when the scan does not have an associated schedule' do
            it 'returns false' do
                subject.schedule = nil

                expect(subject.schedule).to be_falsey
                expect(subject).to_not be_scheduled
            end
        end

        context 'when the scan has an associated schedule' do
            it 'returns true' do
                subject.schedule.start_at = Time.now
                expect(subject).to be_scheduled
            end
        end
    end
end
