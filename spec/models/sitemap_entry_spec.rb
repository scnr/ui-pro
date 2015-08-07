require 'spec_helper'

describe SitemapEntry do
    subject { FactoryGirl.create(:sitemap_entry) }

    expect_it { to belong_to :site }
    expect_it { to belong_to :revision }
    expect_it { to have_many :issues }

    describe :scope do
        describe :with_issues do
            it 'returns entries with issues'
        end

        describe :without_issues do
            it 'returns entries without issues'
        end

        describe :default do
            it 'sorts entries by URL'
        end
    end

    it 'sets #digest' do
        subject.url = 'test'
        subject.save

        expect(subject.digest).to eq 'test'.persistent_hash
    end
end
