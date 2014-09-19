require 'spec_helper'

describe PageDomFunction do
    subject { FactoryGirl.create :page_dom_function }

    expect_it { to belong_to :with_func }

    describe '#arguments' do
        it 'is an Array' do
            expect( subject.arguments ).to be_kind_of Array
        end
    end

end
