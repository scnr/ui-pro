shared_examples_for 'Scans sidebar' do |options = {}|

    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:revision) { FactoryGirl.create :revision, scan: scan }

    let(:profile) { FactoryGirl.create :profile }

    # Provided by parent.
    let(:site) { super() }
    let(:with_scans) { super() }

    def scans_sidebar_refresh
        visit current_url
    end

    before do
        revision
        with_scans.scans << scan
        scan.reload

        scans_sidebar_refresh
    end

    let(:sidebar) { find '#sidebar' }
    let(:scans) { find '#sidebar #sidebar-scans' }
    let(:scans) { sidebar.find '#sidebar-scans' }

    scenario 'user sees name' do
        expect(scans).to have_content scan.name
    end

    scenario 'user sees amount of issues' do
        expect(scans.find('.badge')).to have_content scan.issues.size
    end

    scenario 'user sees profile' do
        expect(scans).to have_content scan.profile
        expect(scans).to have_xpath "//a[@href='#{profile_path( scan.profile )}']"
    end

    scenario 'user sees user agent' do
        expect(scans).to have_content scan.user_agent
        expect(scans).to have_xpath "//a[@href='#{user_agent_path( scan.user_agent )}']"
    end

    scenario 'user sees site role' do
        expect(scans).to have_content scan.site_role
        expect(scans).to have_xpath "//a[@href='#{site_role_path( site, scan.site_role )}']"
    end

    scenario 'user sees scan link with filtering options' do
        expect(scans).to have_xpath "//a[starts-with(@href, '#{site_scan_path( site, scan )}?filter') and not(@data-method)]"
    end

    feature 'when the scan is in progress' do
        before do
            revision.stopped_at = nil
            revision.save

            scans_sidebar_refresh
        end

        scenario 'user sees start datetime' do
            expect(scans).to have_content "#{revision} started on"
            expect(scans).to have_content I18n.l( revision.started_at )
        end

        scenario 'user does not sees stop datetime' do
            expect(scans).to_not have_content 'Performed on'
        end
    end

    feature 'when the scan has been performed' do
        scenario 'user sees stop datetime of last revision' do
            expect(scans).to have_content scan.last_revision.index.ordinalize
            expect(scans).to have_xpath "//a[@href='#{site_scan_revision_path( site, scan, scan.last_revision )}']"
            expect(scans).to have_content I18n.l( revision.performed_at )
        end
    end

    if !options[:without_filtering]
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


                visit "#{current_path}?filter[states][]=trusted&filter[states][]=untrusted&filter[states][]=false_positive&filter[states][]=fixed&filter[severities][]=high&filter[severities][]=medium&filter[severities][]=low&filter[severities][]=informational&filter[type]=include"
            end

            let(:types) { @types.values }
            let(:severities) { @severities.values }

            feature 'when filtering' do
                let(:sitemap_entry) { site.issues.first.vector.sitemap_entry}
                let(:path) { URI(sitemap_entry.url).path }

                feature 'page' do
                    before do
                        visit "#{current_path}?filter[pages][]=#{sitemap_entry.id}&filter[states][]=trusted&filter[states][]=untrusted&filter[states][]=false_positive&filter[states][]=fixed&filter[severities][]=high&filter[severities][]=medium&filter[severities][]=low&filter[severities][]=informational&filter[type]=include"
                    end

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
            end
        end
    end
end
