module IssuesSummary

    def issues_summary_data( data )
        if !data[:scans].is_a?( Array )
            data[:scans] = data[:scans].includes(:revisions).
                includes(:schedule).includes(:profile)
        end

        issues = data[:issues].includes(:referring_page).
            includes(referring_page: :dom).includes(:revision).
            includes(revision: :scan)

        states     = count_states( issues )
        severities = count_severities( issues )

        issues = filter_states( issues )
        issues = filter_severities( issues )

        pre_page_filter_issues = issues

        issue_ids = issues.pluck(:id)

        issues = filter_pages( issues )

        {
            site:                   data[:site],
            site_scans:             data[:site].scans.includes(:revisions).
                                        includes(:schedule).includes(:profile),
            scans:                  data[:scans],
            revisions:              data[:revisions],
            sitemap:                data[:sitemap],
            sitemap_with_issues:    data[:site].sitemap_entries.includes(:revision).
                                        includes(revision: :scan).joins(:issues).
                                        where( 'issues.id IN (?)', issue_ids ),
            issues:                 issues,
            pre_page_filter_issues: pre_page_filter_issues,
            states:                 states,
            severities:             severities,
            chart_data:             chart_data( issues )
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

    def count_severities( issues )
        IssueTypeSeverity::SEVERITIES.inject({}) do |h, severity|
            h.merge! severity => issues.send("#{severity}_severity").count
        end
    end

    def count_states( issues )
        Issue::STATES.inject({}) do |h, state|
            h.merge! state => issues.send(state).count
        end
    end

    def filter_states( issues )
        prepare_issue_filters

        return issues if params[:filter][:states].empty?

        if params[:filter][:type] == 'exclude'
            issues.where.not( state: params[:filter][:states] )
        else
            issues.where( state: params[:filter][:states] )
        end
    end

    def filter_severities( issues )
        prepare_issue_filters

        return issues if params[:filter][:severities].empty?

        if params[:filter][:type] == 'exclude'
            issues.where.not(
                'issue_type_severities.name IN (?)',
                params[:filter][:severities]
            )
        else
            issues.where(
                'issue_type_severities.name IN (?)',
                params[:filter][:severities]
            )
        end
    end

    def filter_pages( issues )
        return issues if params[:filter][:pages].empty?

        @sitemap_entry = SitemapEntry.find( params[:filter][:pages].first )

        issues.joins(:page).where(
            'issues.sitemap_entry_id IN (?) OR issue_pages.sitemap_entry_id IN (?)',
            params[:filter][:pages], params[:filter][:pages]
        )
    end

    def prepare_issue_filters
        params[:filter]              ||= {}
        params[:filter][:type]       ||= 'include'
        params[:filter][:pages]      ||= []
        params[:filter][:states]     ||= %w(trusted)
        params[:filter][:severities] ||=
            IssueTypeSeverity::SEVERITIES.map(&:to_s) - ['informational']
    end

end
