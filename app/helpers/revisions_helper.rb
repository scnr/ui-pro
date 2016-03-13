module RevisionsHelper

    def revision_path( revision )
        site_scan_revision_path( revision.site, revision.scan, revision )
    end

    def events_revision_path( revision )
        events_site_scan_revision_path( revision.site, revision.scan, revision )
    end

end
