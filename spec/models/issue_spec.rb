require 'spec_helper'

describe Issue do
    expect_it { to belong_to :revision }
    expect_it { to belong_to(:page).dependent(:destroy) }
    expect_it { to belong_to(:referring_page).dependent(:destroy) }
    expect_it { to belong_to(:sitemap_entry).counter_cache(true)}
    expect_it { to belong_to :type }
    expect_it { to belong_to :platform }
    expect_it { to have_one :severity  }
    expect_it { to have_one(:vector).dependent(:destroy) }
    expect_it { to have_many(:remarks).dependent(:destroy) }

    IssueTypeSeverity::SEVERITIES.each do |severity|
        let("#{severity}_severity") do
            FactoryGirl.create( :issue_type_severity, name: severity )
        end

        let("#{severity}_severity_type") do
            FactoryGirl.create( :issue_type, severity: send( "#{severity}_severity" ) )
        end

        let("#{severity}_severity_issue") do
            send( "#{severity}_severity_type" ).issues.create
        end
    end

    describe :scopes do
        describe :default do
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

                ha.issues.create
                hc.issues.create
                hb.issues.create

                ma.issues.create
                mc.issues.create
                mb.issues.create

                la.issues.create
                lc.issues.create
                lb.issues.create

                ia.issues.create
                ic.issues.create
                ib.issues.create

                expect(described_class.all.map(&:type).map(&:name)).to eq %w(a1 b1 c1 a2 b2 c2 a3 b3 c3 a4 b4 c4)
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
