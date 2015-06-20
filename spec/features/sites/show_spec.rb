# Feature: Site page
#   As a user
#   I want to visit a site
#   So I can see a site
feature 'Site page' do

    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site }
    let(:profile) { FactoryGirl.create :profile }
    let(:other_site) { FactoryGirl.create :site, host: 'fff.com' }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:other_scan) { FactoryGirl.create :scan, site: site, profile: profile, name: 'Blah' }

    before do
        revision
        user.sites << site

        login_as user, scope: :user
        visit site_path( site )
    end

    after(:each) do
        Warden.test_reset!
    end

    let(:site_info) { find '#site-info' }

    def set_sitemap_entries( issue )
        page_sitemap_entry   = site.sitemap_entries.find_by_url( issue.page.dom.url )
        page_sitemap_entry ||= site.sitemap_entries.create(
            url:      issue.page.dom.url,
            code:     issue.page.response.code,
            revision: revision
        )

        issue.page.sitemap_entry = page_sitemap_entry
        issue.page.save

        page_sitemap_entry   = site.sitemap_entries.find_by_url( issue.referring_page.dom.url )
        page_sitemap_entry ||= site.sitemap_entries.create(
            url:      issue.referring_page.dom.url,
            code:     issue.referring_page.response.code,
            revision: revision
        )

        issue.referring_page.sitemap_entry = page_sitemap_entry
        issue.referring_page.save

        vector_sitemap_entry   = site.sitemap_entries.find_by_url( issue.vector.action )
        vector_sitemap_entry ||= site.sitemap_entries.create(
            url:      issue.vector.action,
            code:     issue.page.response.code,
            revision: revision
        )
        issue.vector.sitemap_entry = vector_sitemap_entry
        issue.vector.save

        issue.sitemap_entry = vector_sitemap_entry
        issue.save
        issue
    end

    scenario 'has title' do
        expect(page).to have_title site.url
        expect(page).to have_title 'Sites'
    end

    scenario 'has breadcrumbs' do
        breadcrumbs = find('ul.bread')

        expect(breadcrumbs.find('li:nth-of-type(1) a').native['href']).to eq root_path

        expect(breadcrumbs.find('li:nth-of-type(2)')).to have_content 'Sites'
        expect(breadcrumbs.find('li:nth-of-type(2) a').native['href']).to eq sites_path

        expect(breadcrumbs.find('li:nth-of-type(3)')).to have_content site.url
        expect(breadcrumbs.find('li:nth-of-type(3) a').native['href']).to eq site_path( site )
    end

    feature 'when the site has no scans' do
        before do
            user.sites << other_site

            login_as user, scope: :user
            visit site_path( other_site )
        end

        scenario 'user sees the new scan form' do
            expect(page).to have_xpath "//form[@id='new_scan']"
        end
    end

    scenario 'user sees the site URL as a heading' do
        expect(site_info.find('h1').text).to match site.url
    end

    feature 'when the site has been scanned' do
        before do
            revision
            site.scans << scan
            site.save

            visit site_path( site )
        end

        scenario 'user sees the time of the last performed' do
            expect(site_info).to have_content 'Last scanned on'
            expect(site_info).to have_content I18n.l( site.last_scanned_at )
        end

        scenario 'user sees last performed scan link' do
            expect(site_info).to have_xpath "//a[@href='#{site_scan_path( site, site.revisions.last.scan )}']"
        end

        scenario 'user sees last revision link' do
            expect(site_info).to have_xpath "//a[@href='#{site_scan_revision_path( site, site.revisions.last.scan, site.revisions.last )}']"
        end
    end

    feature 'when the site is being scanned' do
        before do
            revision.stopped_at = nil
            revision.save

            site.scans << scan
            site.save

            visit site_path( site )
        end

        scenario 'user sees the start time' do
            expect(site_info).to have_content 'Started on'
            expect(site_info).to have_content I18n.l( revision.started_at )
        end

        scenario 'user sees last performed scan link' do
            expect(site_info).to have_xpath "//a[@href='#{site_scan_path( site, site.revisions.last.scan )}']"
        end

        scenario 'user sees last revision link' do
            expect(site_info).to have_xpath "//a[@href='#{site_scan_revision_path( site, site.revisions.last.scan, site.revisions.last )}']"
        end
    end

    feature 'Overview tab' do
        feature 'without revisions' do
            before do
                site.scans.first.revisions.clear
                visit site_path( site )
            end

            scenario 'user sees notice' do
                expect(page).to have_text 'No scan has started yet'
            end
        end

        feature 'with scans' do
            before do
                revision
                site.scans << scan
                scan.reload

                visit site_path( site )
            end

            feature 'sidebar' do
                let(:sidebar) { find '#sidebar' }

                feature 'scan list' do
                    let(:scans) { find '#site-sidebar' }

                    scenario 'user sees name' do
                        expect(scans).to have_content scan.name
                    end

                    scenario 'user sees amount of revisions' do
                        expect(scans).to have_content "#{scan.revisions.size} revision"
                    end

                    scenario 'user sees amount of pages' do
                        expect(scans).to have_content "#{scan.sitemap_entries.size} pages"
                    end

                    scenario 'user sees amount of issues' do
                        expect(scans).to have_content "#{scan.issues.size} issues"
                    end

                    scenario 'user sees profile' do
                        expect(scans).to have_content scan.profile
                        expect(scans).to have_xpath "//a[@href='#{profile_path( scan.profile )}']"
                    end

                    scenario 'user sees link' do
                        expect(scans).to have_xpath "//a[@href='#{site_scan_path( site, scan )}' and not(@data-method)]"
                    end

                    feature 'when the scan is in progress' do
                        before do
                            revision.stopped_at = nil
                            revision.save

                            visit site_path( site )
                        end

                        scenario 'user sees start datetime' do
                            expect(scans).to have_content 'Started on'
                            expect(scans).to have_content I18n.l( revision.started_at )
                        end

                        scenario 'user does not sees stop datetime' do
                            expect(scans).to_not have_content 'Performed on'
                        end
                    end

                    feature 'when the scan has been performed' do
                        scenario 'user sees stop datetime' do
                            expect(scans).to have_content 'Last performed on'
                            expect(scans).to have_content I18n.l( revision.performed_at )
                        end
                    end
                end
            end

            feature 'with issues' do
                before do
                    100.times do |i|
                        site.sitemap_entries.create(
                            url:      "#{site.url}/#{i}",
                            code:     200,
                            revision: site.revisions.sample
                        )
                    end

                    @severities = {}
                    @types      = {}
                    25.times do |i|
                        IssueTypeSeverity::SEVERITIES.each do |severity|
                            @severities[severity] ||=
                                FactoryGirl.create(:issue_type_severity,
                                               name: severity )

                            type_name = "#{severity}-#{rand(25)}"
                            type = @types[type_name] ||= FactoryGirl.create(:issue_type,
                                severity: @severities[severity],
                                name:     "Stuff #{type_name}",
                                check_shortname: type_name
                            )

                            sitemap_entry = site.sitemap_entries.create(
                                url:      "#{site.url}/#{severity}/#{i}",
                                code:     i,
                                revision: site.revisions.sample
                            )

                            set_sitemap_entries revision.issues.create(
                                type:           type,
                                page:           FactoryGirl.create(:issue_page),
                                referring_page: FactoryGirl.create(:issue_page),
                                vector:         FactoryGirl.create(:vector),
                                sitemap_entry:  sitemap_entry,
                                digest:         rand(99999999999999).to_s,
                                state:          'trusted'
                            )
                        end
                    end

                    visit "#{site_path( site )}?filter[states][]=trusted&filter[states][]=untrusted&filter[states][]=false_positive&filter[states][]=fixed&filter[severities][]=high&filter[severities][]=medium&filter[severities][]=low&filter[severities][]=informational&filter[type]=include"
                end

                let(:types) { @types.values }
                let(:severities) { @severities.values }

                feature 'when filtering' do
                    ['Trusted', 'untrusted', 'false positive', 'fixed'].each do |type|
                        feature "#{type} issues for" do
                            feature 'inclusion' do
                                it "shows #{type} issues"
                            end

                            feature 'exclusion' do
                                "it 'does not show #{type} issues'"
                            end
                        end
                    end

                    IssueTypeSeverity::SEVERITIES.each do |type|
                        feature "#{type} severity issues for" do
                            feature 'inclusion' do
                                it "shows #{type} severity issues"
                            end

                            feature 'exclusion' do
                                "it 'does not show #{type} severity issues'"
                            end
                        end
                    end
                end

                feature 'issues' do
                    let(:issues) { find '#summary-issues' }

                    feature 'grouped by severity' do
                        scenario 'user sees color-coded headings' do
                            IssueTypeSeverity::SEVERITIES.each do |severity|
                                expect(issues.find("h3 span.text-severity-#{severity}")).to have_content "#{severity.capitalize} severity"
                            end
                        end

                        scenario 'user sees amount of issues in the heading' do
                            IssueTypeSeverity::SEVERITIES.each do |severity|
                                expect(issues.find("h3 span.badge-severity-#{severity}")).to have_content site.issues.send("#{severity}_severity").size
                            end
                        end

                        feature 'and by issue type' do
                            scenario 'user sees issue type headings' do
                                types.each do |type|
                                    expect(issues.find(".issue-summary-check-#{type.check_shortname} h4")).to have_content type.name
                                end
                            end

                            scenario 'user sees amount of issues in the heading' do
                                types.each do |type|
                                    expect(issues.find(".issue-summary-check-#{type.check_shortname} h4 span.badge-severity-#{type.severity.name}")).to have_content type.issues.size
                                end
                            end

                            feature 'for each issue' do
                                feature 'scan info' do
                                    scenario 'user sees scan name' do
                                        site.issues.each do |issue|
                                            expect(issues.find("#summary-issue-#{issue.digest}")).to have_content issue.revision.scan.name
                                        end
                                    end

                                    scenario 'user sees scan link' do
                                        site.issues.each do |issue|
                                            expect(issues.find("#summary-issue-#{issue.digest}")).to have_xpath "//a[@href='#{site_scan_path(issue.revision.scan.site, issue.revision.scan)}']"
                                        end
                                    end

                                    scenario 'user sees revision index' do
                                        site.issues.each do |issue|
                                            expect(issues.find("#summary-issue-#{issue.digest}")).to have_content issue.revision.index
                                        end
                                    end

                                    scenario 'user sees revision link' do
                                        site.issues.each do |issue|
                                            expect(issues.find("#summary-issue-#{issue.digest}")).to have_xpath "//a[@href='#{site_scan_revision_path(issue.revision.scan.site, issue.revision.scan, issue.revision)}']"
                                        end
                                    end
                                end

                                scenario 'users sees link to the Issue page'

                                scenario 'user sees vector type' do
                                    site.issues.each do |issue|
                                        expect(issues.find("#summary-issue-#{issue.digest}")).to have_content issue.vector.kind
                                    end
                                end

                                feature 'different from the referring page' do
                                    before do
                                        issue
                                        visit site_path( site )
                                    end

                                    let(:issue) do
                                        issue = revision.issues.create(
                                            type:           types.first,
                                            page:           FactoryGirl.create(:issue_page),
                                            referring_page: FactoryGirl.create(:issue_page),
                                            vector:         FactoryGirl.create(:vector, affected_input_name: 'stuff'),
                                            sitemap_entry:  site.sitemap_entries.first,
                                            digest:         rand(99999999999999).to_s,
                                            state:          'trusted'
                                        )

                                        issue.referring_page.dom.url = "#{issue.vector.action}/2"
                                        issue.referring_page.dom.save
                                        set_sitemap_entries issue
                                    end

                                    scenario 'user sees vector action URL without scheme, host and port' do
                                        url = ApplicationHelper.url_without_scheme_host_port( issue.vector.action )
                                        expect(issues.find("#summary-issue-#{issue.digest}")).to have_content url
                                    end
                                end

                                feature 'when the vector has an affected input' do
                                    before do
                                        issue
                                        visit site_path( site )
                                    end

                                    let(:issue) do
                                        set_sitemap_entries revision.issues.create(
                                            type:           types.first,
                                            page:           FactoryGirl.create(:issue_page),
                                            referring_page: FactoryGirl.create(:issue_page),
                                            vector:         FactoryGirl.create(:vector, affected_input_name: 'stuff'),
                                            sitemap_entry:  site.sitemap_entries.first,
                                            digest:         rand(99999999999999).to_s,
                                            state:          'trusted'
                                        )
                                    end

                                    scenario 'it includes input info' do
                                        expect(issues.find("#summary-issue-#{issue.digest}")).to have_content issue.vector.affected_input_name
                                    end
                                end

                                feature 'when the vector does not have an affected input' do
                                    before do
                                        issue
                                        visit site_path( site )
                                    end

                                    let(:issue) do
                                        set_sitemap_entries revision.issues.create(
                                            type:           types.first,
                                            page:           FactoryGirl.create(:issue_page),
                                            referring_page: FactoryGirl.create(:issue_page),
                                            vector:         FactoryGirl.create(:vector, affected_input_name: nil),
                                            sitemap_entry:  site.sitemap_entries.first,
                                            digest:         rand(99999999999999).to_s,
                                            state:          'trusted'
                                        )
                                    end

                                    scenario 'it does not include input info' do
                                        expect(issues.find("#summary-issue-#{issue.digest}")).to_not have_content 'input'
                                    end
                                end
                            end
                        end
                    end
                end

                feature 'sidebar' do
                    let(:sidebar) { find '#sidebar' }

                    feature 'scan list' do
                        let(:scans) { find '#site-sidebar' }

                        scenario 'user sees amount of pages' do
                            expect(scans).to have_content "#{scan.sitemap_entries.size} pages"
                        end

                        scenario 'user sees amount of issues' do
                            expect(scans).to have_content "#{scan.issues.size} issues"
                        end
                    end
                end

                feature 'statistics' do
                    let(:statistics) { find '#summary-statistics' }

                    scenario 'user sees amount of pages with issues' do
                        expect(statistics).to have_text "#{site.sitemap_entries.with_issues.size} page with issues"
                    end

                    scenario 'user sees total amount of pages' do
                        expect(statistics).to have_text "out of #{site.sitemap_entries.size}"
                    end

                    scenario 'user sees amount of issues' do
                        expect(statistics).to have_text "#{site.issues.size} issues"
                    end

                    scenario 'user sees maximum severity of issues' do
                        expect(statistics).to have_text "maximum severity of #{site.issues.max_severity.capitalize}"
                    end

                    scenario 'user sees amount of scan revisions' do
                        expect(statistics).to have_text "#{site.revisions.size} revision"
                    end

                    scenario 'user sees amount of scans' do
                        expect(statistics).to have_text "#{site.scans.size} scan"
                    end

                    scenario 'user sees amount of issues by severity' do
                        IssueTypeSeverity::SEVERITIES.each do |severity|
                            elem = statistics.find(".text-severity-#{severity}")

                            expectation =
                                "#{site.issues.send("#{severity}_severity").size} #{severity}"

                            expect(elem).to have_text expectation
                        end
                    end
                end

                feature 'sitemap' do
                    let(:sitemap) { find '#summary-sitemap' }

                    scenario 'entries filter issues'
                    scenario 'URLs are color-coded by severity'

                    scenario 'user sees amount of pages in the heading' do
                        expect(sitemap.find('h3')).to have_text site.sitemap_entries.with_issues.size
                    end

                    scenario 'includes pages with issues' do
                        site.sitemap_entries.with_issues.each do |entry|
                            expect(sitemap).to have_text ApplicationHelper.url_without_scheme_host_port( entry.url )
                        end
                    end
                end
            end
        end
    end

    feature 'Scans tab' do
        before do
            click_link 'Scans'
        end

        feature 'without scans'

        feature 'with scans' do
            before do
                other_scan.revisions.create
                site.scans << other_scan
            end

            feature 'that are active' do
                let(:scans) { find '#scans-active' }

                scenario 'user sees scan name'
                scenario 'user sees scan profile'
                scenario 'user sees scan status'
                scenario 'user sees amount of pages'
                scenario 'user sees amount of issues'
                scenario 'user sees amount of revisions'
                scenario 'user sees pause button'
                scenario 'user sees suspend button'

                scenario 'user sees edit button' do
                    expect(scans).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
                end

                scenario 'user sees abort button'
            end

            feature 'that are suspended' do
                let(:scans) { find '#scans-suspended' }

                scenario 'user sees scan name'
                scenario 'user sees scan profile'
                scenario 'user sees amount of pages'
                scenario 'user sees amount of issues'
                scenario 'user sees amount of revisions'
                scenario 'user sees repeat button'
                scenario 'user sees resume button'

                scenario 'user sees edit button' do
                    expect(scans).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
                end

                scenario 'user sees delete button' do
                    expect(scans).to have_xpath "//a[@href='#{site_scan_path( site, scan )}' and @data-method='delete']"
                end
            end

            feature 'that are finished' do
                let(:scans) { find '#scans-finished' }

                scenario 'user sees scan name'
                scenario 'user sees scan profile'
                scenario 'user sees amount of pages'
                scenario 'user sees amount of issues'
                scenario 'user sees amount of revisions'
                scenario 'user sees repeat button'

                scenario 'user sees edit button' do
                    expect(scans).to have_xpath "//a[@href='#{edit_site_scan_path( site, scan )}']"
                end

                scenario 'user sees delete button' do
                    expect(scans).to have_xpath "//a[@href='#{site_scan_path( site, scan )}' and @data-method='delete']"
                end
            end
        end
    end
end
