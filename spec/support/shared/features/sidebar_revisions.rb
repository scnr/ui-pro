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

    let(:info) { sidebar.find "#sidebar-revisions-id-#{revision.id}-info" }

    let(:revision_info) { info.find '.revision-info' }
    it_behaves_like 'Revision info', extended: false, hide_revision_name: true

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
        expect(sidebar).to have_xpath "//a[starts-with(@href, '#{site_scan_revision_path( site, scan, revision )}/issues?filter') and not(@data-method)]"
    end

end
