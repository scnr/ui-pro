require 'spec_helper'

describe Issue do
    expect_it { to belong_to :revision }
    expect_it { to belong_to(:page).dependent(:destroy) }
    expect_it { to belong_to(:referring_page).dependent(:destroy) }
    expect_it { to belong_to :type }
    expect_it { to belong_to :platform }
    expect_it { to have_one :severity  }
    expect_it { to have_one(:vector).dependent(:destroy) }
    expect_it { to have_many(:remarks).dependent(:destroy) }

    IssueTypeSeverity::SEVERITIES.each do |severity|
        let(severity) do
            FactoryGirl.create( :issue_type,
                severity: FactoryGirl.create( :issue_type_severity, name: severity )
            ).issues.create
        end
    end

    describe :scopes do
        IssueTypeSeverity::SEVERITIES.each do |severity|
            describe "#{severity}_severity" do
                it "returns #{severity} severity issues" do

                    # Create issues of all severities
                    IssueTypeSeverity::SEVERITIES.each do |s|
                        send( s )
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

    describe '.create_from_arachni' do
        let(:arachni_issue) do
            Factory[:issue]
        end

        it "creates a #{described_class} from #{Arachni::Issue}" do
            platform = IssuePlatform.create(
                shortname: arachni_issue.platform_name,
                name:      arachni_issue.platform_name.to_s.upcase
            )

            issue = described_class.create_from_arachni( arachni_issue ).reload
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
    end

end
