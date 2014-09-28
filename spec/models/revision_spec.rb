require 'spec_helper'

describe Revision do
    subject { FactoryGirl.create :revision, scan: scan }
    let(:other_revision) { FactoryGirl.create :revision, scan: scan }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }

    expect_it { to belong_to(:scan).counter_cache(true) }
    expect_it { to have_many(:issues).dependent(:destroy) }
    expect_it { to have_many(:sitemap_entries) }

    describe '#index' do
        it 'returns the index of the revision' do
            expect(subject.index).to eq 1
            expect(other_revision.index).to eq 2
        end
    end
end
