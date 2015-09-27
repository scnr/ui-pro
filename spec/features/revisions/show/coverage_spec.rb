feature 'Revision coverage' do
    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site, user: user }
    let(:profile) { FactoryGirl.create :profile }
    let(:other_site) { FactoryGirl.create :site, host: 'fff.com' }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:revision_root) { FactoryGirl.create :revision, scan: scan }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:revision_last) { FactoryGirl.create :revision, scan: scan }

    def refresh
        visit current_url
        click_link 'Coverage'
    end

    before do
        revision_root.aborted!
        revision_root.index = 1
        revision_root.save

        revision.completed!
        revision.index = 2
        revision.save

        revision_last.completed!
        revision_last.index = 3
        revision_last.save

        revision_root.sitemap_entries.create(
            url:  missing_entry_1,
            code: 200,
            coverage: true
        )
        revision_root.sitemap_entries.create(
            url:  missing_entry_3,
            code: 200,
            coverage: true
        )
        revision_root.sitemap_entries.create(
            url:  revisited_entry_1,
            code: 200,
            coverage: true
        )

        revision.sitemap_entries.create(
            url:  missing_entry_2,
            code: 200,
            coverage: true
        )
        revision.sitemap_entries.create(
            url:  missing_entry_4,
            code: 200,
            coverage: true
        )
        revision.sitemap_entries.create(
            url:  revisited_entry_2,
            code: 200,
            coverage: true
        )
        revision.sitemap_entries.create(
            url:  revisited_entry_3,
            code: 200,
            coverage: true
        )

        new_entries.each do |entry|
            revision_last.sitemap_entries.create(
                url:  entry,
                code: 200,
                coverage: true
            )
        end

        revisited_entries.each do |entry|
            revision_last.sitemap_entries.create(
                url:  entry,
                code: 200,
                coverage: true
            )
        end

        user.sites << site

        login_as user, scope: :user
    end

    after(:each) do
        Warden.test_reset!
    end

    let(:scan_results) { find '#scan-results' }
    let(:coverage) { find '#coverage' }
    let(:coverage_list) { coverage_section.find 'ul' }

    let(:new_entry_1) { "#{scan.url}/new-entry/1" }
    let(:new_entry_2) { "#{scan.url}/new-entry/2" }
    let(:new_entries) { [new_entry_1, new_entry_2] }

    let(:revisited_entry_1) { "#{scan.url}/revisited-entry/1" }
    let(:revisited_entry_2) { "#{scan.url}/revisited-entry/2" }
    let(:revisited_entry_3) { "#{scan.url}/revisited-entry/3" }
    let(:revisited_entries) { [revisited_entry_1, revisited_entry_2, revisited_entry_3] }

    let(:missing_entry_1) { "#{scan.url}/missing-entry/1" }
    let(:missing_entry_2) { "#{scan.url}/missing-entry/2" }
    let(:missing_entry_3) { "#{scan.url}/missing-entry/3" }
    let(:missing_entry_4) { "#{scan.url}/missing-entry/4" }
    let(:missing_entries) { [missing_entry_1, missing_entry_2, missing_entry_3, missing_entry_4] }

    let(:help_alert) { find '.alert-help' }

    feature 'help alert' do
        before do
            visit coverage_site_scan_revision_path( site, scan, revision_root )
        end

        scenario 'shows link to concurrency setting', js: true do
            within help_alert do
                click_link 'customize the site-wide scope'
                expect( current_url ).to end_with "#{edit_site_path( site )}#!/scope"
            end
        end
    end

    feature 'when the revision is the root one' do
        before do
            visit site_scan_revision_path( site, scan, revision_root )
            click_link 'Coverage'
        end

        it 'shows flat coverage' do
            expect(scan_results).to have_css 'div#coverage div#coverage-flat'
        end
    end

    feature 'when the revision is not the root one' do
        before do
            visit site_scan_revision_path( site, scan, revision_last )
            click_link 'Coverage'
        end

        let(:coverage) { scan_results.find '#coverage #coverage-incremental' }
        let(:coverage_section) { coverage.find "##{coverage_section_id}" }
        let(:coverage_bar) { find "##{coverage_section_id}-bar" }
        let(:coverage_bar_pct) { coverage_bar.find 'span' }

        feature 'when the revision is active' do
            before do
                revision_last.performance_snapshot.current_page = "#{scan.url}#{current_page}"
                revision_last.performance_snapshot.save

                revision_last.scanning!
                refresh
            end
            let(:current_page) { '/stuff/here?name=val#!/frag/path/' }

            scenario 'shows currently audited page' do
                expect(scan_results.find('h3#coverage-current-url')).to have_content current_page
            end
        end

        feature 'when the revision not active' do
            before do
                revision_last.performance_snapshot.current_page = "#{scan.url}#{current_page}"
                revision_last.performance_snapshot.save

                revision_last.suspended!
                refresh
            end
            let(:current_page) { '/stuff/here?name=val#!/frag/path/' }

            scenario 'does not show currently audited page' do
                expect(scan_results).to_not have_css 'h3#coverage-current-url'
            end
        end

        feature 'and it has new entries' do
            let(:coverage_section_id) { 'coverage-new' }

            it 'includes a count of the entries in the heading' do
                tab = coverage_section.find( :xpath, "h2//span[@class='badge badge-severity-none']" )
                expect(tab).to have_content new_entries.size
            end

            it 'lists new entries' do
                new_entries.each do |entry|
                    coverage_entry = coverage_list.find("#coverage-entry-#{entry.persistent_hash}")

                    expect(coverage_entry.find('a')).to have_content URI(entry).path
                    expect(coverage_entry).to have_xpath "//a[@href='#{entry}' and @target='_blank']"
                end
            end

            it 'shows the % in the progress bar' do
                expect(coverage_bar_pct).to have_content '22.2%'
            end

            it 'sets the progress bar width' do
                expect(coverage_bar[:style]).to have_content 'width: 22.22222222222222%'
            end

            feature 'when clicking the bar', js: true do
                it 'sets the URL fragment for the section ID' do
                    coverage_bar.click

                    expect(URI(current_url).fragment).to eq "!/#{coverage_section_id.gsub( '-', '/' )}"
                end
            end

            feature 'when the revision is active' do
                before do
                    revision.scanning!
                    refresh
                end

                scenario 'progress bas is active' do
                    expect(coverage_bar[:class]).to have_content 'active'
                end
            end

            feature 'when the revision is not active' do
                before do
                    revision.suspended!
                    refresh
                end

                scenario 'progress bas is not active' do
                    expect(coverage_bar[:class]).to_not have_content 'active'
                end
            end
        end

        feature 'and it has entries found in previous revisions' do
            let(:coverage_section_id) { 'coverage-revisited' }

            it 'includes a count of the entries in the heading' do
                tab = coverage_section.find( :xpath, "h2//span[@class='badge badge-severity-informational']" )
                expect(tab).to have_content revisited_entries.size
            end

            it 'lists revisited entries' do
                revisited_entries.each do |entry|
                    coverage_entry = coverage_list.find("#coverage-entry-#{entry.persistent_hash}")

                    expect(coverage_entry.find('a')).to have_content URI(entry).path
                    expect(coverage_entry).to have_xpath "//a[@href='#{entry}' and @target='_blank']"
                end
            end

            it 'shows the % in the progress bar' do
                expect(coverage_bar_pct).to have_content '33.3%'
            end

            it 'sets the progress bar width' do
                expect(coverage_bar[:style]).to have_content 'width: 33.33333333333333%'
            end

            feature 'when clicking the bar', js: true do
                it 'sets the URL fragment for the section ID' do
                    coverage_bar.click

                    expect(URI(current_url).fragment).to eq "!/#{coverage_section_id.gsub( '-', '/' )}"
                end
            end

            feature 'when the revision is active' do
                before do
                    revision.scanning!
                    refresh
                end

                scenario 'progress bas is active' do
                    expect(coverage_bar[:class]).to have_content 'active'
                end
            end

            feature 'when the revision is not active' do
                before do
                    revision.suspended!
                    refresh
                end

                scenario 'progress bas is not active' do
                    expect(coverage_bar[:class]).to_not have_content 'active'
                end
            end
        end

        feature 'and it does not have entries from previous revisions' do
            let(:coverage_section_id) { 'coverage-missing' }

            it 'includes a count of the entries in the heading' do
                tab = coverage_section.find( :xpath, "h2//span[@class='badge badge-severity-medium']" )
                expect(tab).to have_content missing_entries.size
            end

            it 'lists missing entries' do
                missing_entries.each do |entry|
                    coverage_entry = coverage_list.find("#coverage-entry-#{entry.persistent_hash}")

                    expect(coverage_entry.find('a')).to have_content URI(entry).path
                    expect(coverage_entry).to have_xpath "//a[@href='#{entry}' and @target='_blank']"
                end
            end

            it 'shows the % in the progress bar' do
                expect(coverage_bar_pct).to have_content '44.4%'
            end

            it 'sets the progress bar width' do
                expect(coverage_bar[:style]).to have_content 'width: 44.44444444444444%'
            end

            feature 'when clicking the bar', js: true do
                it 'sets the URL fragment for the section ID' do
                    coverage_bar.click

                    expect(URI(current_url).fragment).to eq "!/#{coverage_section_id.gsub( '-', '/' )}"
                end
            end

            feature 'when the revision is active' do
                before do
                    revision.scanning!
                    refresh
                end

                scenario 'progress bas is active' do
                    expect(coverage_bar[:class]).to have_content 'active'
                end
            end

            feature 'when the revision is not active' do
                before do
                    revision.suspended!
                    refresh
                end

                scenario 'progress bas is not active' do
                    expect(coverage_bar[:class]).to_not have_content 'active'
                end
            end
        end
    end

    feature 'when there are no sitemap entries at all' do
        before do
            revision_root.sitemap_entries = []
            revision_root.save

            revision.sitemap_entries = []
            revision.save

            visit site_scan_revision_path( site, scan, revision )
            click_link 'Coverage'
        end

        let(:coverage) { scan_results.find '#coverage' }

        it 'shows info alert' do
            expect(coverage.find('.alert.alert-info.no-coverage')).to have_content 'No coverage data are available.'
        end
    end
end
