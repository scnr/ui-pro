feature 'Site issues', js: true do
    include SiteRolesHelper

    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create(:user, email: 'other@example.com') }
    let(:site) { FactoryGirl.create :site }
    let(:profile) { FactoryGirl.create :profile }
    let(:other_site) { FactoryGirl.create :site, host: 'fff.com' }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:other_revision) { FactoryGirl.create :revision, scan: other_scan }
    let(:other_scan) { FactoryGirl.create :scan, site: site, profile: profile, name: 'Blah' }

    before do
        revision
        user.sites << site

        login_as user, scope: :user
        visit site_path( site )

        click_link 'Issues'
    end

    after(:each) do
        Warden.test_reset!
    end

    let(:site_info) { find '#site-info' }

    feature 'without revisions' do
        before do
            FactoryGirl.create( :scan, site: other_site, profile: profile )

            user.sites << other_site

            visit site_path( other_site )
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

        feature 'with issues' do
            let(:issues) { find '#summary-issues' }

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
                revision    = nil
                25.times do |i|
                    if (i % 5) == 0
                        scan     = FactoryGirl.create( :scan, site: site, profile: profile )
                        revision = FactoryGirl.create( :revision, scan: scan )
                    end

                    IssueTypeSeverity::SEVERITIES.each do |severity|
                        @severities[severity] ||=
                            FactoryGirl.create(:issue_type_severity,
                                               name: severity )

                        type_name = "#{severity}-#{rand(25)}"
                        type = @types[type_name] ||= FactoryGirl.create(
                            :issue_type,
                            severity: @severities[severity],
                            name:     "Stuff #{type_name}",
                            check_shortname: type_name
                        )

                        sitemap_entry = site.sitemap_entries.create(
                            url:      "#{site.url}/#{severity}/#{i}",
                            code:     i,
                            revision: revision
                        )

                        set_sitemap_entries revision.issues.create(
                            type:           type,
                            page:           FactoryGirl.create(:issue_page),
                            referring_page: FactoryGirl.create(:issue_page),
                            vector:         FactoryGirl.create(:vector).
                                                tap { |v| v.action = sitemap_entry.url },
                            sitemap_entry:  sitemap_entry,
                            digest:         rand(99999999999999),
                            state:          'trusted'
                        )
                    end
                end

                visit "#{site_path( site )}?filter[states][]=trusted&filter[states][]=untrusted&filter[states][]=false_positive&filter[states][]=fixed&filter[severities][]=high&filter[severities][]=medium&filter[severities][]=low&filter[severities][]=informational&filter[type]=include"
            end

            let(:types) { @types.values }
            let(:severities) { @severities.values }

            feature 'when filtering' do
                let(:sitemap_entry) { site.issues.first.vector.sitemap_entry}
                let(:path) { URI(sitemap_entry.url).path }

                feature 'page' do
                    feature 'with issues' do
                        before do
                            visit "#{site_path( site )}?filter[pages][]=#{sitemap_entry.digest}&filter[states][]=trusted&filter[states][]=untrusted&filter[states][]=false_positive&filter[states][]=fixed&filter[severities][]=high&filter[severities][]=medium&filter[severities][]=low&filter[severities][]=informational&filter[type]=include"
                        end

                        scenario 'only shows issues for that page' do
                            all_digests = site.issues.pluck(:digest)
                            sitemap_digests = sitemap_entry.issues.pluck(:digest)

                            sitemap_digests.each do |digest|
                                expect(issues).to have_css "#summary-issue-#{digest}"
                            end

                            expect(all_digests - sitemap_digests).to be_any

                            (all_digests - sitemap_digests).each do |digest|
                                expect(issues).to_not have_css "#summary-issue-#{digest}"
                            end
                        end

                        feature 'sidebar' do
                            let(:sidebar) { find '#sidebar-scans' }

                            scenario 'only shows scans that have logged issues for that page' do
                                all_scans  = site.scans.pluck(:name)
                                page_scans = sitemap_entry.issues.map { |i| i.scan }.map(&:name)

                                page_scans.each do |name|
                                    expect(sidebar).to have_content name
                                end

                                expect(all_scans - page_scans).to be_any

                                (all_scans - page_scans).each do |name|
                                    expect(sidebar).to_not have_content name
                                end
                            end
                        end

                        scenario 'user sees the page URL in the heading' do
                            expect(site_info.find('h1')).to have_content "showing #{path}"
                        end
                    end

                    feature 'without issues' do
                        before do
                            visit "#{site_path( site )}?filter[pages][]=#{sitemap_entry.digest}&filter[states][]=trusted&filter[states][]=untrusted&filter[states][]=false_positive&filter[states][]=fixed&filter[severities][]=high&filter[severities][]=medium&filter[severities][]=low&filter[severities][]=informational&filter[type]=exclude"
                        end

                        let(:message) do
                            find( '#issues-summary div.well' )
                        end

                        scenario 'shows message' do
                            expect(message).to have_content 'No issues for'
                        end

                        scenario 'message includes internal page URL' do
                            expect(message).to have_xpath "//a[@href='#{sitemap_entry.url}']"
                        end

                        scenario 'message includes external page URL' do
                            expect(message).to have_xpath "//a[@href='#{sitemap_entry.url}']"
                        end

                        scenario 'message includes URL without page filter'
                    end
                end

                states = ['Trusted', 'untrusted', 'false positive', 'fixed']
                states.each do |type|
                    state = type.sub( ' ', '_' ).downcase

                    feature "#{type} issues for" do
                        before do
                            states.each do |t|
                                uncheck t

                                set_sitemap_entries revision.issues.create(
                                    type:           IssueType.first,
                                    page:           FactoryGirl.create(:issue_page),
                                    referring_page: FactoryGirl.create(:issue_page),
                                    vector:         FactoryGirl.create(:vector).
                                                        tap { |v| v.action = sitemap_entry.url },
                                    sitemap_entry:  sitemap_entry,
                                    digest:         rand(99999999999999),
                                    state:          t.sub( ' ', '_' ).downcase
                                )
                            end

                            expect(revision.reload.issues).to be_any

                            check type
                        end

                        let(:other_issues) { revision.issues.where.not state: state }
                        let(:state_issues) { revision.issues.where state: state }

                        feature 'inclusion' do
                            before do
                                IssueTypeSeverity::SEVERITIES.each do |severity|
                                    check severity
                                end

                                expect(state_issues).to be_any
                                expect(other_issues).to be_any

                                click_button 'Show'

                                other_issues.each do |issue|
                                    expect(issues).to_not have_css "#summary-issue-#{issue.digest}"
                                end
                            end

                            it "shows #{type} issues" do
                                state_issues.each do |issue|
                                    expect(issues).to have_css "#summary-issue-#{issue.digest}"
                                end
                            end
                        end

                        feature 'exclusion' do
                            before do
                                IssueTypeSeverity::SEVERITIES.each do |severity|
                                    uncheck severity
                                end

                                expect(state_issues).to be_any
                                expect(other_issues).to be_any

                                click_button 'Hide'

                                other_issues.each do |issue|
                                    expect(issues).to have_css "#summary-issue-#{issue.digest}"
                                end
                            end

                            it "does not show #{type} issues" do
                                state_issues.each do |issue|
                                    expect(issues).to_not have_css "#summary-issue-#{issue.digest}"
                                end
                            end
                        end
                    end
                end

                IssueTypeSeverity::SEVERITIES.each do |severity|
                    feature "#{severity} severity issues for" do
                        before do
                            IssueTypeSeverity::SEVERITIES.each do |s|
                                uncheck s

                                @severities[s] ||=
                                    FactoryGirl.create(:issue_type_severity,
                                                       name: s )

                                type_name = "#{s}-#{rand(999999999999)}"
                                @types[s] ||= FactoryGirl.create(
                                    :issue_type,
                                    severity: @severities[s],
                                    name:     "Stuff #{type_name}",
                                    check_shortname: type_name
                                )

                                set_sitemap_entries revision.issues.create(
                                    type:           @types[s],
                                    page:           FactoryGirl.create(:issue_page),
                                    referring_page: FactoryGirl.create(:issue_page),
                                    vector:         FactoryGirl.create(:vector).
                                                        tap { |v| v.action = sitemap_entry.url },
                                    sitemap_entry:  sitemap_entry,
                                    digest:         rand(99999999999999),
                                    state:          'trusted'
                                )
                            end

                            expect(revision.reload.issues).to be_any

                            check severity
                        end

                        let(:other_issues) do
                            revision.issues.joins(:severity).where.
                                not( 'issue_type_severities.name = ?', severity )
                        end
                        let(:severity_issues) { revision.issues.send( "#{severity}_severity" ) }

                        feature 'inclusion' do
                            before do
                                states.each do |state|
                                    uncheck state
                                end

                                expect(severity_issues).to be_any
                                expect(other_issues).to be_any

                                click_button 'Show'

                                other_issues.each do |issue|
                                    expect(issues).to_not have_css "#summary-issue-#{issue.digest}"
                                end
                            end

                            it "shows #{severity} severity issues" do
                                severity_issues.each do |issue|
                                    expect(issues).to have_css "#summary-issue-#{issue.digest}"
                                end
                            end
                        end

                        feature 'exclusion' do
                            before do
                                states.each do |state|
                                    uncheck state
                                end

                                expect(severity_issues).to be_any
                                expect(other_issues).to be_any

                                click_button 'Hide'

                                severity_issues.each do |issue|
                                    expect(issues).to_not have_css "#summary-issue-#{issue.digest}"
                                end
                            end

                            it "shows all but #{severity} severity issues" do
                                other_issues.each do |issue|
                                    expect(issues).to have_css "#summary-issue-#{issue.digest}"
                                end
                            end
                        end
                    end
                end
            end

            feature 'issues' do
                feature 'grouped by severity' do
                    scenario 'user sees color-coded containers' do
                        IssueTypeSeverity::SEVERITIES.each do |severity|
                            expect(issues.find("div#issue-summary-severity-#{severity}")[:class]).to include "bg-severity-#{severity}"
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

                                scenario 'user sees scan link with filtering options' do
                                    site.issues.each do |issue|
                                        expect(issues.find("#summary-issue-#{issue.digest}")).to have_xpath "//a[starts-with(@href, '#{site_scan_path(issue.revision.scan.site, issue.revision.scan)}?filter')]"
                                    end
                                end

                                scenario 'user sees revision index' do
                                    site.issues.each do |issue|
                                        expect(issues.find("#summary-issue-#{issue.digest}")).to have_content issue.revision.index
                                    end
                                end

                                scenario 'user sees revision link with filtering options' do
                                    site.issues.each do |issue|
                                        expect(issues.find("#summary-issue-#{issue.digest}")).to have_xpath "//a[starts-with(@href, '#{site_scan_revision_path(issue.revision.scan.site, issue.revision.scan, issue.revision)}?filter')]"
                                    end
                                end

                                feature 'when the same issue has been logged by different scans' do
                                    let(:sibling) do
                                        issue  = site.issues.last

                                        set_sitemap_entries other_revision.issues.create(
                                            type:           issue.type,
                                            page:           FactoryGirl.create(:issue_page),
                                            referring_page: FactoryGirl.create(:issue_page),
                                            vector:         FactoryGirl.create(:vector).
                                                                tap { |v| v.action = issue.sitemap_entry.url },
                                            sitemap_entry:  issue.sitemap_entry,
                                            digest:         issue.digest,
                                            state:          'trusted'
                                        )
                                    end

                                    before do
                                        sibling
                                        visit current_url
                                    end

                                    scenario 'user sees scan name' do
                                        expect(issues.find("#summary-issue-#{sibling.digest}")).to have_content sibling.revision.scan.name
                                    end

                                    scenario 'user sees scan link with filtering options' do
                                        expect(issues.find("#summary-issue-#{sibling.digest}")).to have_xpath "//a[starts-with(@href, '#{site_scan_path(sibling.revision.scan.site, sibling.revision.scan)}?filter')]"
                                    end

                                    scenario 'user sees revision index' do
                                        expect(issues.find("#summary-issue-#{sibling.digest}")).to have_content sibling.revision.index
                                    end

                                    scenario 'user sees revision link with filtering options' do
                                        expect(issues.find("#summary-issue-#{sibling.digest}")).to have_xpath "//a[starts-with(@href, '#{site_scan_revision_path(sibling.revision.scan.site, sibling.revision.scan, sibling.revision)}?filter')]"
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
                                        digest:         rand(99999999999999),
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
                                        digest:         rand(99999999999999),
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
                                        digest:         rand(99999999999999),
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

            feature 'statistics' do
                let(:statistics) { find '#summary-statistics' }

                scenario 'user sees amount of pages with issues' do
                    expect(statistics).to have_text "#{site.sitemap_entries.with_issues.size} pages with issues"
                end

                scenario 'user sees total amount of pages' do
                    expect(statistics).to have_text "out of #{site.reload.sitemap_entries.size}"
                end

                scenario 'user sees amount of issues' do
                    expect(statistics).to have_text "#{site.issues.size} issues"
                end

                scenario 'user sees maximum severity of issues' do
                    expect(statistics).to have_text "maximum severity of #{site.issues.max_severity.capitalize}"
                end

                scenario 'user sees amount of scan revisions' do
                    expect(statistics).to have_text "#{site.reload.revisions.size} revision"
                end

                scenario 'user sees amount of scans' do
                    expect(statistics).to have_text "#{site.reload.scans.size} scan"
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
                scenario 'entries filter scans'

                scenario 'URLs are color-coded by max severity'
                scenario 'shows amount of issues per entry'

                scenario 'user sees amount of pages' do
                    expect(sitemap.find('#sitemap-entry-all')).to have_text site.sitemap_entries.with_issues.size
                end

                scenario 'includes pages with issues' do
                    site.sitemap_entries.with_issues.each do |entry|
                        expect(sitemap).to have_text ApplicationHelper.url_without_scheme_host_port( entry.url )
                    end
                end

                feature 'when filtering criteria exclude some issues' do
                    scenario 'the shown info only refers to the included issues'
                end

                feature 'when no entry is selected' do
                    scenario 'the All link is .active' do
                        expect(sitemap.find( '#sitemap-entry-all' )[:class]).to include 'active'
                    end
                end

                feature 'when an entry is selected' do
                    scenario 'becomes .active'
                end
            end
        end

        feature 'without issues' do
            scenario 'shows notice'

            feature 'and a filtered page' do
                feature 'which has issues' do
                    scenario 'lists revisions which have issues for it'
                    scenario 'lists scans which have issues for it'
                end
            end
        end
    end
end
