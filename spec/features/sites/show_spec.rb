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

    after(:each) do
        Warden.test_reset!
    end

    # Scenario: User cannot see an unassociated site
    #   Given I am signed in
    #   When I try to see an unassociated site
    #   Then I get a 404 error
    scenario "user cannot cannot see another user's site" do
        user.sites << site
        login_as user, scope: :user

        expect { visit site_path( other_site ) }.to raise_error ActionController::RoutingError
    end

    feature 'when the site has scans' do
        before do
            site.verification.verified!

            scan
            user.sites << site

            login_as user, scope: :user
        end

        feature 'with revisions' do
            before do
                revision
                visit site_path( site )
            end

            scenario 'the Summary tab is active' do
                expect(page).to have_xpath "//div[@id='summary' and @class='tab-pane active']"
            end
        end

        feature 'without revisions' do
            before do
                visit site_path( site )
            end

            scenario 'the Scans tab is active' do
                expect(page).to have_xpath "//div[@id='scans' and @class='tab-pane active']"
            end
        end

    end

    feature 'when the site has no scans' do
        before do
            site.verification.verified!

            user.sites << site

            login_as user, scope: :user
            visit site_path( site )
        end

        feature 'the Scans tab is active' do
            scenario 'and shows the new scan form' do
                expect(page).to have_xpath "//form[@id='new_scan']"
            end
        end
    end

    feature 'with unverified site' do
        before { site.verification.failed! }

        feature 'owned by the user' do
            before do
                user.sites << site

                login_as user, scope: :user
                visit site_path( site )
            end

            # Scenario: User sees "Access denied" when trying to access own unverified site
            #   Given I am signed in
            #   When I visit one of my sites
            #   And it is not verified
            #   Then I see "Access denied"
            scenario 'user sees "Access denied" message' do
                expect(page).to have_content 'Access denied'
            end

            # Scenario: User gets redirected to homepage when trying to access own unverified site
            #   Given I am signed in
            #   When I visit one of my sites
            #   And it is not verified
            #   Then I gets redirected back to the homepage
            scenario 'user gets redirected bash to the homepage' do
                expect(current_url).to match root_path
            end
        end
    end

    feature 'with verified site' do
        before { site.verification.verified! }

        feature 'owned by the user' do
            before do
                revision
                user.sites << site

                login_as user, scope: :user
                visit site_path( site )
            end

            scenario 'user sees the site URL as a heading' do
                expect(find('h1').text).to match site.url
            end

            feature 'Summary tab' do
                feature 'without issues' do
                    scenario 'user sees notice' do
                        expect(page).to have_text 'No issues'
                    end
                end

                feature 'with issues' do
                    before do
                        other_scan.revisions.create
                        site.scans << other_scan

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

                                revision.issues.create(
                                    type:          type,
                                    vector:        FactoryGirl.create(:vector),
                                    sitemap_entry: sitemap_entry,
                                    digest:        rand(99999999999999).hash.to_s
                                )
                            end
                        end

                        visit site_path( site )
                    end

                    let(:types) { @types.values }
                    let(:severities) { @severities.values }

                    feature 'statistics' do
                        let(:statistics) { find '#summary-statistics' }

                        scenario 'user sees amount of pages with issues' do
                            expect(statistics).to have_text "#{site.sitemap_entries.with_issues.size} pages with issues"
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
                            expect(statistics).to have_text "#{site.revisions.size} scan revisions"
                        end

                        scenario 'user sees amount of scans' do
                            expect(statistics).to have_text "#{site.scans.size} base scans"
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

                        scenario 'user sees amount of pages in the heading' do
                            expect(sitemap.find('h3')).to have_text site.sitemap_entries.with_issues.size
                        end

                        scenario 'includes pages with issues' do
                            site.sitemap_entries.with_issues.each do |entry|
                                expect(sitemap).to have_text ApplicationHelper.url_without_scheme_host_port( entry.url )
                            end
                        end

                        scenario 'includes HTTP response status code' do
                            site.sitemap_entries.with_issues.each do |entry|
                                expect(sitemap).to have_text entry.code
                            end
                        end

                        scenario 'URLs are color-coded by severity'
                    end

                    feature 'issues' do
                        let(:issues) { find '#summary-issues' }

                        feature 'grouped by severity' do
                            # scenario 'user sees high severity issues' do
                            #     site.issues.high_severity.each do |issue|
                            #         expect(issues)
                            #     end
                            # end
                            #
                            # scenario 'user sees medium severity issues'
                            # scenario 'user sees low severity issues'
                            # scenario 'user sees informational severity issues'

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
                                                expect(issues.find("#summary-issue-#{issue.digest} ul.issue-summary-info")).to have_content issue.revision.scan.name
                                            end
                                        end

                                        scenario 'user sees scan link' do
                                            site.issues.each do |issue|
                                                expect(issues.find("#summary-issue-#{issue.digest} ul.issue-summary-info li span")).to have_xpath "//a[@href='#{site_scan_path(issue.revision.scan.site, issue.revision.scan)}']"
                                            end
                                        end

                                        scenario 'user sees revision index' do
                                            site.issues.each do |issue|
                                                expect(issues.find("#summary-issue-#{issue.digest} ul.issue-summary-info")).to have_content issue.revision.index
                                            end
                                        end

                                        scenario 'user sees revision link' do
                                            site.issues.each do |issue|
                                                expect(issues.find("#summary-issue-#{issue.digest} ul.issue-summary-info li span")).to have_xpath "//a[@href='#{site_scan_revision_path(issue.revision.scan.site, issue.revision.scan, issue.revision)}']"
                                            end
                                        end
                                    end

                                    scenario 'user sees vector type' do
                                        site.issues.each do |issue|
                                            expect(issues.find("#summary-issue-#{issue.digest}")).to have_content issue.vector.kind
                                        end
                                    end

                                    scenario 'user sees vector action URL without scheme, host and port' do
                                        site.issues.each do |issue|
                                            expect(issues.find("#summary-issue-#{issue.digest}")).to have_content ApplicationHelper.url_without_scheme_host_port( issue.vector.action )
                                        end
                                    end

                                    feature 'when the vector has an affected input' do
                                        before do
                                            issue
                                            visit site_path( site )
                                        end

                                        let(:issue) do
                                            revision.issues.create(
                                                type:          types.first,
                                                vector:        FactoryGirl.create(:vector, affected_input_name: 'stuff'),
                                                sitemap_entry: site.sitemap_entries.first,
                                                digest:        rand(99999999999999).hash.to_s
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
                                            revision.issues.create(
                                                type:          types.first,
                                                vector:        FactoryGirl.create(:vector, affected_input_name: nil),
                                                sitemap_entry: site.sitemap_entries.first,
                                                digest:        rand(99999999999999).hash.to_s
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
                end
            end
        end

        feature 'shared with the user' do
            before do
                user.shared_sites << site
                login_as user, scope: :user

                visit site_path( site )
            end

            feature 'Summary tab' do
            end
        end
    end
end
