shared_examples_for 'Revisions sidebar' do |options = {}|
    let(:site) { FactoryGirl.create :site }
    let(:scan) { FactoryGirl.create :scan, site: site, profile: profile }
    let(:revision) { FactoryGirl.create :revision, scan: scan }
    let(:other_revision) { FactoryGirl.create :revision, scan: scan }

    let(:profile) { FactoryGirl.create :profile }

    let(:sidebar) { find '#sidebar #sidebar-revisions' }

    def revisions_sidebar_refresh
        visit current_url
    end

    before do
        revision
        revisions_sidebar_refresh
    end

    scenario 'user sees index' do
        expect(sidebar).to have_content "##{revision.index}"
    end

    scenario 'user sees amount of new pages' do
        revision.sitemap_entries.create(
            url:  revision.scan.url,
            code: 200
        )

        revisions_sidebar_refresh
        revision.reload

        sz = revision.sitemap_entries.size

        expect(sidebar).to have_content "#{sz} #{'page'.pluralize sz}"
    end

    scenario 'user sees amount of new issues'

    scenario 'user sees amount of auto-reviewed issues'

    scenario 'user sees revision link with filtering options' do
        expect(sidebar).to have_xpath "//a[starts-with(@href, '#{site_scan_revision_path( site, scan, revision )}?filter') and not(@data-method)]"
    end

    feature 'when the revision is in progress' do
        before do
            other_revision.stopped_at = nil
            other_revision.save

            revision.stopped_at = nil
            revision.save

            revisions_sidebar_refresh
        end

        scenario 'user sees start datetime' do
            expect(sidebar).to have_content 'Started on'
            expect(sidebar).to have_content I18n.l( revision.started_at )
        end

        scenario 'user does not sees stop datetime' do
            expect(sidebar).to_not have_content 'Performed on'
        end
    end

    feature 'when the revision has been performed' do
        scenario 'user sees stop datetime' do
            expect(sidebar).to have_content 'Performed on'
            expect(sidebar).to have_content I18n.l( revision.performed_at )
        end
    end

end
