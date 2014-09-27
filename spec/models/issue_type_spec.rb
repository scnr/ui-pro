require 'spec_helper'

describe IssueType do
    expect_it { to belong_to :severity }
    expect_it { to have_and_belong_to_many :tags }
    expect_it { to have_many(:references).dependent(:destroy) }
    expect_it { to have_many :issues }

    IssueTypeSeverity::SEVERITIES.each do |severity|
        let("#{severity}_severity") do
            FactoryGirl.create( :issue_type_severity, name: severity )
        end

        let("#{severity}_severity_type") do
            FactoryGirl.create( :issue_type, severity: send( "#{severity}_severity" ) )
        end
    end

    describe :scopes do
        describe :default do
            it 'orders by severity' do
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

                expect(described_class.pluck(:name)).to eq %w(a1 c1 b1 a2 c2 b2 a3 c3 b3 a4 c4 b4)
            end
        end

    end
end
