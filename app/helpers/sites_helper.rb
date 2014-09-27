module SitesHelper

    def chart_data
        data = {
            issue_names:              {},
            severity_index_for_issue: {},
            severity_regions:         {}
        }

        last_severity = nil
        IssueType.all.each do |type|
            data[:issue_names][type.name] = @site.issues.where( type: type ).size

            data[:severity_index_for_issue][type.name] ||= 0
            data[:severity_index_for_issue][type.name] =
                IssueTypeSeverity::SEVERITIES.reverse.index( type.severity.to_sym ) + 1

            new_region = !data[:severity_regions].include?( type.severity.to_sym )

            data[:severity_regions][type.severity.to_sym] ||= {}
            data[:severity_regions][type.severity.to_sym][:class]  =
                "severity-#{type.severity.to_sym}"
            data[:severity_regions][type.severity.to_sym][:start] ||=
                data[:issue_names].size - 1

            if new_region && last_severity
                data[:severity_regions][last_severity][:end] =
                    data[:issue_names].size - 2
            end
            last_severity = type.severity.to_sym
        end
        data[:severity_regions] = data[:severity_regions].values

        data
    end

end
