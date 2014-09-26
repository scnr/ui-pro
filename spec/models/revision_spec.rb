require 'spec_helper'

describe Revision do
    subject { FactoryGirl.create :revision, scan: scan }
    let(:other_revision) { FactoryGirl.create :revision  }
    let(:scan) { FactoryGirl.create :scan, site: site }
    let(:site) { FactoryGirl.create :site }

    expect_it { to belong_to :scan }
    expect_it { to have_many(:issues).dependent(:destroy) }
    expect_it { to have_many(:sitemap_entries) }

    describe '#index' do
        it 'returns the index of the revision' do
            expect(subject.index).to eq 1
            scan.revisions << other_revision
            expect(other_revision.index).to eq 2
        end
    end
end
