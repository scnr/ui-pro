module SitesHelper

    def chart_data
        data = {
            issue_names:              {},
            severities:               {},
            severity_index_for_issue: {},
            severity_regions:         {}
        }

        last_severity = nil
        IssueType.all.each do |type|
            issue_count = @site.issues.where( type: type ).size
            next if issue_count == 0

            severity = type.severity.to_sym

            data[:issue_names][type.name] = @site.issues.where( type: type ).size

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
