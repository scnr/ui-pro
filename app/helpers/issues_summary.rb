module IssuesSummary

    def issues_summary_data( data )
        if !data[:scans].is_a?( Array )
            data[:scans] = data[:scans].includes(:revisions).includes(:schedule).
                includes(:profile).includes(:plan)
        end

        {
            site:       data[:site],
            site_scans: data[:site].scans.includes(:revisions).
                            includes(:schedule).includes(:profile).
                            includes(:plan),
            scans:      data[:scans],
            revisions:  data[:revisions],
            sitemap:    data[:sitemap].includes(:revision).
                            includes(revision: :scan),
            sitemap_with_issues:  data[:site].sitemap_entries.
                            includes(:revision).includes(revision: :scan).
                            where( issues: { id: data[:issues].pluck(:id) } ),
            issues:     data[:issues].includes(:referring_page).
                            includes(referring_page: :dom).
                            includes(:revision).includes(revision: :scan),
            chart_data: chart_data( data[:issues] )
        }
    end

    def chart_data( issues )
        data = {
            issue_names:              {},
            severities:               {},
            severity_index_for_issue: {},
            severity_regions:         {}
        }

        last_severity = nil

        type_ids = issues.group(:issue_type_id).pluck(:issue_type_id)
        IssueType.where( id: type_ids ).each do |type|
            severity = type.severity.to_sym

            data[:issue_names][type.name] = issues.where( type: type ).size

            data[:severities][severity] ||= 0
            data[:severities][severity]  += data[:issue_names][type.name]

            data[:severity_index_for_issue][type.name] ||= 0
            data[:severity_index_for_issue][type.name] =
                IssueTypeSeverity::SEVERITIES.reverse.index( severity ) + 1

            new_region = !data[:severity_regions].include?( severity )

            data[:severity_regions][severity] ||= {}
            data[:severity_regions][severity][:class]  =
                "severity-#{severity}"
            data[:severity_regions][severity][:start] ||=
                data[:issue_names].size - 1

            if new_region && last_severity
                data[:severity_regions][last_severity][:end] =
                    data[:issue_names].size - 2
            end
            last_severity = severity
        end
        data[:severity_regions] = data[:severity_regions].values

        data
    end
end
