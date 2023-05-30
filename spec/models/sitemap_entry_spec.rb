# frozen_string_literal: true

RSpec.describe SitemapEntry do
    subject { FactoryGirl.create(:sitemap_entry) }

    expect_it { to belong_to(:site).optional }
    expect_it { to belong_to(:revision).optional }
    expect_it { to have_many :issues }

    describe 'scope' do
        describe 'coverage' do
            before do
                FactoryGirl.create(
                    :sitemap_entry,
                    url: '1',
                    code: 200
                )
                FactoryGirl.create(
                    :sitemap_entry,
                    url: '2',
                    code: 404
                )
                FactoryGirl.create(
                    :sitemap_entry,
                    url: '3',
                    code: 301,
                    coverage: true
                )

                @coverage = []
                @coverage << FactoryGirl.create(
                    :sitemap_entry,
                    url: '4',
                    code: 200,
                    coverage: true
                )
                @coverage << FactoryGirl.create(
                    :sitemap_entry,
                    url: '5 ',
                    code: 200,
                    coverage: true
                )
            end

            it 'returns entries with marked as coverage and code 200' do
                expect(described_class.coverage.map(&:url).sort).to eq @coverage.map(&:url).sort
            end
        end

        describe ':with_issues' do
            it 'returns entries with issues'
        end

        describe ':without_issues' do
            it 'returns entries without issues'
        end

        describe ':default' do
            it 'sorts entries by URL'
        end
    end

    it 'sets #digest' do
        subject.url = 'test'
        subject.save

        expect(subject.digest).to eq 'test'.persistent_hash
    end

    describe 'broadcast callbacks' do
        let(:queue_name) { 'anycable' }

        describe 'after_create_commit' do
            subject(:sitemap_entry) { build(:sitemap_entry, scan: scan, site: site, revision: nil) }

            let(:scan) { build(:scan, site: site) }
            let(:site) { build(:site, user: user) }
            let(:user) { create(:user) }

            before do
                site.save(validate: false)
                scan.save(validate: false)
            end

            it 'enqueues Broadcasts::Scans::UpdateJob' do
                expect { sitemap_entry.save }.to have_enqueued_job(Broadcasts::Scans::UpdateJob).with(sitemap_entry.scan.id).on_queue(queue_name)
            end

            it 'enqueues Broadcasts::ScanResults::UpdateJob' do
                expect { sitemap_entry.save }.to have_enqueued_job(Broadcasts::ScanResults::UpdateJob).with(user.id).on_queue(queue_name)
            end
        end
    end
end
