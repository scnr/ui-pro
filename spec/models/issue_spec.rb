require 'spec_helper'

describe Issue do
    expect_it { to belong_to :revision }
    expect_it { to belong_to :page }
    expect_it { to belong_to :referring_page }
    expect_it { to belong_to :type }
    expect_it { to belong_to :platform }
    expect_it { to have_one :vector }
    expect_it { to have_many :remarks }

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
