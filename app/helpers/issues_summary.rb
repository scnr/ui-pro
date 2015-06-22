module IssuesSummary

    def issues_summary_data( data )
        if !data[:scans].is_a?( Array )
            data[:scans] = data[:scans].includes(:revisions).
                includes(:schedule).includes(:profile)
        end

        issues = data[:issues].includes(:site).includes(:scan).includes(:revision).
            includes(:type).includes(:severity).
            includes(:vector).includes( vector: :sitemap_entry )

        # This needs to happen here, we want this for filtering feedback and
        # thus has to refer to the big, pre-filtering picture.
        states     = issues.count_states
        severities = issues.count_severities

        issues = filter_issues_by_severity_and_state( issues )

        sitemap_with_issues  = {}
        chart_data           = {}
        pre_page_filter_data = {}

        page_filtered_issues = []
        max_severity         = nil

        pre_page_filter_data[:count] = issues.size

        # Page filters should not affect the sitemap because it needs to show
        # all pages, so it takes place here.
        #
        # And since these issues are a superset of the post-filtered issues,
        # calculate the chart data here and perform the filtering on a per-issue
        # basis, instead of performing yet another iteration over the filtered
        # relation.
        scoped_find_each( issues, size: pre_page_filter_data[:count] ) do |issue|
            # Issues are sorted by severity, first one will be the max.
            pre_page_filter_data[:max_severity] ||= issue.severity.to_s

            update_chart_data( chart_data, issue )
            update_sitemap_data( sitemap_with_issues, issue )

            # First level page issue filtering here...
            if filter_pages? && !page_id_in_filter?( issue.vector.sitemap_entry_id )
                next
            end

            #... because we at least want to grab the filtered max severity now...
            max_severity ||= issue.severity.to_s

            # ... but only store the issues if their count is bellow the acceptable
            # batch size.
            if pre_page_filter_data[:count] > ApplicationHelper::SCOPED_FIND_EACH_BATCH_SIZE
                next
            end

            page_filtered_issues << issue
        end

        if chart_data[:severity_regions]
            chart_data[:severity_regions] = chart_data[:severity_regions].values
        end

        # If the total issues are above the batch size, apply any page filtering
        # via a scope.
        if pre_page_filter_data[:count] > ApplicationHelper::SCOPED_FIND_EACH_BATCH_SIZE
            page_filtered_issues = filter_pages( issues )
        end

        if filter_pages?
            @sitemap_entry = @site.sitemap_entries.find( params[:filter][:pages].first )
        end

        {
            site:                 data[:site],
            site_scans:           data[:site].scans.includes(:revisions).
                                      includes(:schedule).includes(:profile),
            scans:                data[:scans],
            revisions:            data[:revisions],
            sitemap:              data[:sitemap],
            sitemap_with_issues:  sitemap_with_issues,
            states:               states,
            severities:           severities,
            pre_page_filter_data: pre_page_filter_data,
            max_severity:         max_severity,
            issues:               page_filtered_issues,
            chart_data:           chart_data
        }
    end

    def update_sitemap_data( data, issue )
        data[issue.vector.action] ||= {
            internal:     sitemap_entry_url( issue.vector.sitemap_entry_id ),

            # Issues are sorted by severity first, the first one will be the max.
            max_severity: issue.severity.to_s,
            id:           issue.vector.sitemap_entry_id,
            issue_count:  0
        }

        data[issue.vector.action][:issue_count] += 1
    end

    def update_chart_data( data, issue )
        if data.empty?
            data.merge!(
                issue_names:              {},
                severities:               {},
                severity_index_for_issue: {},
                severity_regions:         {}
            )
        end

        if filter_pages? && !page_id_in_filter?( issue.vector.sitemap_entry_id )
            return
        end

        severity      = issue.severity.to_sym
        name          = issue.type.name
        last_severity = data[:last_severity]

        data[:issue_names][name] ||= 0
        data[:issue_names][name]  += 1

        data[:severities][severity] ||= 0
        data[:severities][severity]  += 1

        data[:severity_index_for_issue][name] ||= 0
        data[:severity_index_for_issue][name] =
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

        data[:last_severity] = severity
    end

    def filter_params
        prepare_issue_filters
        { filter: params[:filter] }
    end

    def filter_params_without_page
        prepare_issue_filters

        np         = params[:filter].dup
        np[:pages] = []
        { filter: np }
    end

    def filter_issues_by_severity_and_state( issues )
        filter_severities( filter_states( issues ) )
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

    def filter_pages?
        params[:filter][:pages].any?
    end

    def page_id_in_filter?( page_id )
        params[:filter][:pages].include? page_id.to_s
    end

    def filter_pages( issues )
        return issues if !filter_pages?

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
