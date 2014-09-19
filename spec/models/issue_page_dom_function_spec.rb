require 'spec_helper'

describe IssuePageDomFunction do
    subject { FactoryGirl.create :issue_page_dom_function }

    expect_it { to belong_to :with_dom_function }

    describe '#arguments' do
        it 'is an Array' do
            expect( subject.arguments ).to be_kind_of Array
        end
    end

end
