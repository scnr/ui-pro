require 'spec_helper'

describe IssueTypeSeverity do
    expect_it { to have_many :types }
    expect_it { to have_many :issues }

    SEVERITIES = [:high, :medium, :low, :informational]

    SEVERITIES.each do |severity|
        let(severity) { FactoryGirl.create(:issue_type_severity, name: severity) }
    end

    before do
        SEVERITIES.each { |severity| send severity }
    end

    SEVERITIES.each do |severity|
        describe ".#{severity}" do
            it "returns the #{severity} severity model" do
                expect(described_class.send(severity).name).to eq severity.to_s
            end
        end
    end

end
