require 'spec_helper'

describe Issue do
    expect_it { to belong_to :revision }
    expect_it { to belong_to :reviewed_by_revision }
    expect_it { to belong_to(:page).dependent(:destroy) }
    expect_it { to belong_to(:referring_page).dependent(:destroy) }
    expect_it { to belong_to(:sitemap_entry).counter_cache(true)}
    expect_it { to belong_to :type }
    expect_it { to belong_to :platform }
    expect_it { to have_one :severity  }
    expect_it { to have_one(:vector).dependent(:destroy) }
    expect_it { to have_many(:remarks).dependent(:destroy) }

    expect_it { to validate_presence_of :state }

    IssueTypeSeverity::SEVERITIES.each do |severity|
        let("#{severity}_severity") do
            FactoryGirl.create( :issue_type_severity, name: severity )
        end

        let("#{severity}_severity_type") do
            FactoryGirl.create( :issue_type, severity: send( "#{severity}_severity" ) )
        end

        let("#{severity}_severity_issue") do
            send( "#{severity}_severity_type" ).issues.create( state: 'trusted', revision: revision )
        end
    end

    let(:arachni_issue) do
        Factory[:issue]
    end

    let(:site) do
        FactoryGirl.create( :site )
    end

    let(:scan) do
        FactoryGirl.create( :scan, site: site )
    end

    let(:revision) do
        FactoryGirl.create( :revision, scan: scan )
    end

    describe 'scopes' do
        describe 'default' do
            it 'orders issues by severity and type name' do
                ha = FactoryGirl.create( :issue_type,
                                    name: 'a1',
                                    severity: high_severity
                )
                hc = FactoryGirl.create( :issue_type,
                                         name: 'c1',
                                         severity: high_severity
                )
                hb = FactoryGirl.create( :issue_type,
                                         name: 'b1',
                                         severity: high_severity
                )

                ma = FactoryGirl.create( :issue_type,
                                        name: 'a2',
                                        severity: medium_severity
                )
                mc = FactoryGirl.create( :issue_type,
                                         name: 'c2',
                                         severity: medium_severity
                )
                mb = FactoryGirl.create( :issue_type,
                                         name: 'b2',
                                         severity: medium_severity
                )

                la = FactoryGirl.create( :issue_type,
                                        name: 'a3',
                                        severity: low_severity
                )
                lc = FactoryGirl.create( :issue_type,
                                         name: 'c3',
                                         severity: low_severity
                )
                lb = FactoryGirl.create( :issue_type,
                                         name: 'b3',
                                         severity: low_severity
                )

                ia = FactoryGirl.create( :issue_type,
                                         name: 'a4',
                                         severity: informational_severity
                )
                ic = FactoryGirl.create( :issue_type,
                                         name: 'c4',
                                         severity: informational_severity
                )
                ib = FactoryGirl.create( :issue_type,
                                         name: 'b4',
                                         severity: informational_severity
                )

                ha.issues.create( state: 'trusted', revision: revision )
                hc.issues.create( state: 'trusted', revision: revision )
                hb.issues.create( state: 'trusted', revision: revision )

                ma.issues.create( state: 'trusted', revision: revision )
                mc.issues.create( state: 'trusted', revision: revision )
                mb.issues.create( state: 'trusted', revision: revision )

                la.issues.create( state: 'trusted', revision: revision )
                lc.issues.create( state: 'trusted', revision: revision )
                lb.issues.create( state: 'trusted', revision: revision )

                ia.issues.create( state: 'trusted', revision: revision )
                ic.issues.create( state: 'trusted', revision: revision )
                ib.issues.create( state: 'trusted', revision: revision )

                expect(described_class.all.map(&:type).map(&:name)).to eq %w(a1 b1 c1 a2 b2 c2 a3 b3 c3 a4 b4 c4)
            end
        end

        Issue::STATES.each do |state|
            describe state do
                it "returns #{state} issues" do

                    # Create issues of all states
                    Issue::STATES.each do |s|
                        described_class.create( state: s, revision: revision )
                    end

                    issues = Issue.send( state )
                    expect(Issue.count).to be > issues.size

                    expect( issues ).to be_any
                    issues.each do |issue|
                        issue.state == state
                    end
                end
            end
        end

        IssueTypeSeverity::SEVERITIES.each do |severity|
            describe "#{severity}_severity" do
                it "returns #{severity} severity issues" do

                    # Create issues of all severities
                    IssueTypeSeverity::SEVERITIES.each do |s|
                        send( "#{s}_severity_issue" )
                    end

                    issues = Issue.send( "#{severity}_severity" )
                    expect(Issue.count).to be > issues.size

                    expect( issues ).to be_any
                    issues.each do |issue|
                        issue.severity.name == severity.to_s
                    end
                end
            end
        end
    end

    describe '.digests' do
        it 'returns unique digests' do
            type = FactoryGirl.create(
                :issue_type,
                name: 'a1',
                severity: high_severity
            )

            type.issues.create(
                state: 'trusted',
                revision: revision,
                digest: 1
            )

            type.issues.create(
                state: 'trusted',
                revision: revision,
                digest: 1
            )

            type.issues.create(
                state: 'trusted',
                revision: revision,
                digest: 2
            )

            expect(type.issues.digests.sort).to eq [1,2].sort
        end
    end

    describe '.max_severity' do
        context 'when there is an issue with a severity of high' do
            it 'returns high'
        end

        context 'when there is an issue with a severity of medium' do
            it 'returns medium'
        end

        context 'when there is an issue with a severity of low' do
            it 'returns low'
        end

        context 'when there is an issue with a severity of informational' do
            it 'returns informational'
        end

        context 'when there are no issues' do
            it 'returns nil'
        end
    end

    describe '#update_state' do
        let(:digest) { rand(9999999) }
        let(:state) { 'fixed' }

        let(:type) do
            FactoryGirl.create(
                :issue_type,
                name: 'a1',
                severity: high_severity
            )
        end

        let(:sibling) do
            type.issues.create(
                state: 'trusted',
                revision: revision,
                digest: digest
            )
        end

        subject do
            type.issues.create(
                state: 'trusted',
                revision: revision,
                digest: digest
            )
        end

        scenario 'sets the #state' do
            subject.update_state  state
            expect(subject.reload.state).to eq state
        end

        scenario 'sets the #state issues with the same #digest' do
            sibling
            subject.update_state  state

            expect(subject.reload.state).to eq state
            expect(sibling.reload.state).to eq state
        end

        context 'when a revision is given' do
            it 'sets it as the #reviewed_by_revision' do
                sibling
                subject.update_state state, revision

                expect(subject.reload.reviewed_by_revision).to eq revision
                expect(sibling.reload.reviewed_by_revision).to eq revision
            end
        end

        context 'when a revision is not given' do
            it 'removes the #reviewed_by_revision' do
                sibling
                subject.update_state state, revision

                expect(subject.reload.reviewed_by_revision).to eq revision
                expect(sibling.reload.reviewed_by_revision).to eq revision

                subject.update_state state

                expect(subject.reload).to_not be_reviewed_by_revision
                expect(sibling.reload).to_not be_reviewed_by_revision
            end
        end
    end

    describe '#reviewed_by_revision?' do
        let(:fixer_revision) do
            FactoryGirl.create( :revision, scan: scan )
        end
        subject do
            FactoryGirl.create(
                :issue_type,
                name: 'a1',
                severity: high_severity
            ).issues.create(
                state: 'trusted',
                revision: revision
            )
        end

        context 'there is an associated #reviewed_by_revision' do
            subject do
                s = super()
                s.reviewed_by_revision = fixer_revision
                s
            end

            it 'returns true' do
                expect(subject).to be_reviewed_by_revision
            end
        end

        context 'there is no associated #reviewed_by_revision' do
            it 'returns false' do
                expect(subject).to_not be_reviewed_by_revision
            end
        end
    end

    describe '.unique_revisions' do
        it 'returns unique revisions' do
            r1 = FactoryGirl.create( :revision, scan: scan )
            r2 = FactoryGirl.create( :revision, scan: scan )
            r3 = FactoryGirl.create( :revision, scan: scan )

            type = FactoryGirl.create(
                 :issue_type,
                 name: 'a1',
                 severity: high_severity
            )

            type.issues.create(
                state: 'trusted',
                revision: r1
            )
            type.issues.create(
                state: 'trusted',
                revision: r1
            )
            type.issues.create(
                state: 'trusted',
                revision: r1
            )

            type.issues.create(
                state: 'trusted',
                revision: r2
            )
            type.issues.create(
                state: 'trusted',
                revision: r2
            )

            i = type.issues.create(
                state: 'trusted',
                revision: r3
            )

            unique_revisions = described_class.unique_revisions

            expect(unique_revisions).to be_kind_of Revision::ActiveRecord_Relation
            expect(unique_revisions.pluck(:id).sort).to eq [r1.id, r2.id, r3.id].sort
        end
    end

    describe '.create_from_arachni' do
        let(:platform) do
            IssuePlatform.create(
                shortname: arachni_issue.platform_name,
                name:      arachni_issue.platform_name.to_s.upcase
            )
        end

        before do
            platform
        end

        it "creates a #{described_class} from #{Arachni::Issue}" do
            issue = described_class.create_from_arachni(
                arachni_issue,
                revision: revision
            )
            expect(issue).to be_valid

            expect(issue.page).to be_kind_of IssuePage
            expect(issue.page).to be_valid

            expect(issue.referring_page).to be_kind_of IssuePage
            expect(issue.referring_page).to be_valid

            expect(issue.vector).to be_kind_of Vector
            expect(issue.vector).to be_valid

            expect(issue.platform).to eq platform

            expect(issue.remarks).to be_any
            issue.remarks.each do |remark|
                expect(remark).to be_kind_of IssueRemark
                expect(remark).to be_valid
            end
        end

        context 'when :state is given' do
            it 'sets it' do
                issue = described_class.create_from_arachni(
                    arachni_issue,
                    revision: revision,
                    state: 'fixed'
                )
                expect(issue).to be_fixed
            end
        end
    end

    describe '.state_from_native_issue' do
        context 'when the issue is trusted' do
            let(:issue) do
                arachni_issue.trusted = true
                arachni_issue
            end

            it 'returns trusted' do
                expect(described_class.state_from_native_issue( issue )).to eq 'trusted'
            end
        end

        context 'when the issue is untrusted' do
            let(:issue) do
                arachni_issue.trusted = false
                arachni_issue
            end

            it 'returns trusted' do
                expect(described_class.state_from_native_issue( issue )).to eq 'untrusted'
            end
        end
    end

end
