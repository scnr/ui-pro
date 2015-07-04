describe ScanScheduler::Helpers::Issue do
    subject { ScanScheduler.instance }

    let(:revision) { new_revision }
    let(:other_revision) { FactoryGirl.create :revision, scan: scan }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }
    let(:native_issue) { Factory[:issue] }

    def new_revision
        FactoryGirl.create :revision, scan: scan
    end

    before do
        subject.reset
    end

    describe '#create_issue' do
        it "delegates to #{Issue}.create_from_arachni" do
            expect(Issue).to receive(:create_from_arachni).
                                 with( native_issue, revision: revision )

            subject.create_issue( revision, native_issue )
        end
    end

    describe '#update_issue' do
        let(:issue) do
            native_issue.remarks.clear
            subject.create_issue( revision, native_issue )
        end

        it 'creates new remarks' do
            issue

            native_issue.add_remark :dude, 'stuff'

            subject.update_issue( revision, native_issue )
            expect(issue.remarks.where( author: 'dude', text: 'stuff' )).to be_any
        end

        it 'updates the issue state' do
            issue

            native_issue.trusted = false
            subject.update_issue( revision, native_issue )

            expect(issue.reload.state).to eq 'untrusted'
        end

        %w(false_positive fixed).each do |state|
            context "when the state is original state is '#{state}'" do
                it 'does not alter the state' do
                    issue.state = state
                    issue.save

                    subject.update_issue( revision, native_issue )
                    expect(issue.state).to eq state
                end
            end
        end
    end

    describe '#mark_other_issues_fixed' do
        it 'marks issues of other revisions not in the issue list as fixed' do
            issue = subject.create_issue( revision, native_issue )
            issue.digest = rand(9999999)
            issue.save

            issue = subject.create_issue( other_revision, native_issue )

            subject.mark_other_issues_fixed( revision, revision.issues.digests )

            expect(issue.reload.state).to eq 'fixed'
        end
    end

    describe '#import_issues_from_report' do
        let(:report) { Factory[:report].tap { |r| r.options[:url] = 'http://test.com' } }

        context 'when the report contains new issues' do
            it 'creates them' do
                subject.import_issues_from_report( revision, report )
                expect(revision.issues.digests.sort).to eq report.issues.map(&:digest).sort
            end
        end

        context 'when the report contains some issues from previous revisions' do
            it 'only creates new issues' do
                first_issue = report.issues[0]
                first_issue = first_issue.variations.first.to_solo( first_issue )

                rev2 = new_revision
                Issue.create_from_arachni( first_issue, revision: rev2 )

                report.issues = [report.issues[0], report.issues[1]]
                subject.import_issues_from_report(revision, report)

                expect(revision.issues.digests).to eq [report.issues[1].digest]
            end
        end

        context 'when the report contains issues from the current revision' do
            context 'with new remark data' do
                it 'updates the remark data' do
                    first_issue = report.issues[0]
                    first_issue = first_issue.variations.first.to_solo( first_issue )

                    first_issue.remarks.clear
                    first_issue.add_remark 'author', 'text'

                    Issue.create_from_arachni( first_issue, revision: revision )

                    report.issues[0].variations.first.remarks.clear
                    report.issues[0].variations.first.add_remark 'author2', 'text2'

                    report.issues = [report.issues[0]]
                    subject.import_issues_from_report(revision, report)

                    rem1, rem2 = revision.issues.first.remarks.all

                    expect(rem1.author).to eq 'author'
                    expect(rem1.text).to eq 'text'

                    expect(rem2.author).to eq 'author2'
                    expect(rem2.text).to eq 'text2'
                end
            end

            context 'with new status' do
                it 'updates their status' do
                    first_issue = report.issues[0]
                    first_issue = first_issue.variations.first.to_solo( first_issue )

                    first_issue.trusted = true

                    Issue.create_from_arachni( first_issue, revision: revision )
                    expect(revision.issues.first.state).to eq 'trusted'

                    report.issues[0].variations.first.trusted = false
                    report.issues = [report.issues[0]]
                    subject.import_issues_from_report(revision, report)

                    expect(revision.issues.first.state).to eq 'untrusted'
                end
            end
        end
    end
end
