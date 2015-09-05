shared_examples_for 'Coverage' do |options = {}|
    let(:with_sitemap_entries) { super() }

    def flat_coverage_refresh
        visit current_url
        click_link 'Coverage'
    end

    before do
        flat_coverage_refresh
    end

    after(:each) do
        Warden.test_reset!
    end

    let(:scan_results) { find '#scan-results' }
    let(:coverage) { scan_results.find '#coverage #coverage-flat' }
    let(:coverage_list) { coverage.find 'ul' }

    feature 'when there are coverage entries' do
        before do
            with_sitemap_entries.sitemap_entries.create(
                url:  "#{scan.url}/1",
                code: 200,
                coverage: true
            )

            with_sitemap_entries.sitemap_entries.create(
                url:  "#{scan.url}/2",
                code: 405,
                coverage: true
            )

            with_sitemap_entries.sitemap_entries.create(
                url:  "#{scan.url}/3",
                code: 200,
                coverage: true
            )
            with_sitemap_entries.sitemap_entries.create(
                url:  "#{scan.url}/4",
                code: 200,
                coverage: true
            )
            with_sitemap_entries.sitemap_entries.create(
                url:  "#{scan.url}/4",
                code: 200,
                coverage: true
            )

            flat_coverage_refresh
        end

        it 'includes a count of the entries in the tab' do
            tab = scan_results.find( :xpath, "//li[@id='coverage-tab']//a//span[@class='badge']" )
            expect(tab).to have_content 3
        end

        it 'lists unique sitemap entry paths from all revisions' do
            with_sitemap_entries.sitemap_entries.coverage.each do |entry|
                coverage_entry = coverage_list.find("#coverage-entry-#{entry.digest}")

                expect(coverage_entry.find('a')).to have_content URI(entry.url).path
                expect(coverage_entry).to have_xpath "//a[@href='#{entry.url}' and @target='_blank']"
            end
        end

        it 'includes response codes' do
            with_sitemap_entries.sitemap_entries.coverage.each do |entry|
                coverage_entry = coverage_list.find("#coverage-entry-#{entry.digest}")
                expect(coverage_entry.find('code')).to have_content entry.code
            end
        end
    end

    feature 'when there are no coverage entries' do
        before do
            with_sitemap_entries.sitemap_entries.create(
                url:  "#{scan.url}/1",
                code: 405,
                coverage: true
            )

            with_sitemap_entries.sitemap_entries.create(
                url:  scan.url,
                code: 200
            )

            flat_coverage_refresh
        end

        it 'shows info alert' do
            expect(scan_results.find( '#coverage .alert.alert-info')).to have_content 'No coverage data are available.'
        end
    end
end
