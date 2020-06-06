module Features
    module IssueHelpers

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

            vector_sitemap_entry   = site.sitemap_entries.find_by_url( issue.input_vector.action )
            vector_sitemap_entry ||= site.sitemap_entries.create(
                url:      issue.input_vector.action,
                code:     issue.page.response.code,
                revision: revision
            )
            issue.input_vector.sitemap_entry = vector_sitemap_entry
            issue.input_vector.save

            issue.sitemap_entry = vector_sitemap_entry
            issue.save
            issue
        end

    end
end
