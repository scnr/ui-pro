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
        expect(scans.find("#site-sidebar-scan-id-#{scan.id} .badge")).to have_content scan.issues.size
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
end
