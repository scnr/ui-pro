module IssuesSummary

    def prepare_issues_summary_data( data )
        @issues_summary = issues_summary_data( data )

        @reviewed_issues_summary = issues_summary_data(
            data.merge(
                issues: data[:reviewed_issues],

                # Don't filter by revision, we've already passed filtered issues.
                filter_by_revision: false,
                filter_by_state_and_severity: false
            )
        )
    end

    def issues_summary_data( data )
        filter_by_revision = data.include?(:filter_by_revision) ?
            data[:filter_by_revision] : true

        filter_by_state_and_severity = data.include?(:filter_by_state_and_severity) ?
            data[:filter_by_state_and_severity] : true

        if !data[:scans].is_a?( Array )
            data[:scans] = data[:scans].includes(:revisions).
                includes(:schedule).includes(:profile)
        end

        issues = preload_issue_associations( data[:issues] )

        if filter_pages?
            @sitemap_entry = @site.sitemap_entries.where( digest: params[:filter][:pages].first ).first
        end

        # This needs to happen here, we want this for filtering feedback and
        # thus has to refer to the big, pre-filtering picture.
        if @revision
            states     = issues.where( revision: @revision ).count_states
            severities = issues.where( revision: @revision ).count_severities
        else
            states     = issues.count_states
            severities = issues.count_severities
        end

        if filter_by_state_and_severity
            issues = filter_issues_by_severity_and_state( issues )
        end

        sitemap_with_issues  = {}
        chart_data           = {}
        pre_page_filter_data = {}
        scan_data            = {}
        revision_data        = {}
        unique_issues_count  = Set.new

        page_filtered_issues = []
        max_severity         = nil

        pre_page_filter_data[:count] = issues.size

        # If we're filtering by page, also filter out scans and revisions which
        # haven't logged issues for it.
        if filter_pages?
            data[:scans]     = Set.new
            data[:revisions] = Set.new
        end

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

            if !(filter_by_revision && @revision && @revision.id != issue.revision.id)
                update_chart_data( chart_data, issue )
                update_sitemap_data( sitemap_with_issues, issue )
            end

            # First level page issue filtering here...
            if filter_pages?
                next if @sitemap_entry.digest != issue.vector.sitemap_entry.digest &&
                    @sitemap_entry.digest != issue.page.sitemap_entry.digest

                # Only include scans and revisions for issues for the page
                # and scan we're filtering for.
                data[:scans] << issue.scan
                data[:revisions] << issue.revision
            end

            unique_issues_count << issue.digest

            #... because we at least want to grab the filtered max severity now...
            max_severity ||= issue.severity.to_s

            scan_data[issue.scan_id] ||= {}
            scan_data[issue.scan_id][:max_severity] ||= issue.severity.to_s

            scan_data[issue.scan_id][:issue_count] ||= 0
            scan_data[issue.scan_id][:issue_count]  += 1

            revision_data[issue.revision_id] ||= {}
            revision_data[issue.revision_id][:max_severity] ||= issue.severity.to_s

            revision_data[issue.revision_id][:issue_count] ||= 0
            revision_data[issue.revision_id][:issue_count]  += 1

            next if filter_by_revision && @revision && @revision.id != issue.revision.id

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

            if @revision
                page_filtered_issues = page_filtered_issues.where( revision: @revision )
            end
        end

        sitemap_data = {
            issue_count: 0
        }

        if sitemap_with_issues.any?
            sitemap_data[:max_severity] =
                sitemap_with_issues.values.first[:max_severity]

            sitemap_data[:issue_count]  =
                sitemap_with_issues.values.map{ |v| v[:issue_count] }.inject(:+)
        end

        if @revision && revision_data[@revision.id]
            max_severity = revision_data[@revision.id][:max_severity]
        end

        if data[:revisions].is_a? Set
            data[:revisions] = data[:revisions].sort_by { |r| r.id }.reverse
        end

        if data[:scans].is_a? Set
            data[:scans] = data[:scans].sort_by { |r| r.id }.reverse
        end

        sitemap_current_digests             = Set.new
        sitemap_up_to_now_exclusive_digests = Set.new
        sitemap_up_to_now_inclusive         = {}

        if @revision && @revision.index > 1
            sitemap_current_digests.merge data[:sitemap].reorder('').pluck(:digest)

            SitemapEntry.where(
                revision: @scan.revisions.reorder( id: :asc )[0..(@revision.index-1)]
            ).each do |entry|
                sitemap_up_to_now_inclusive[entry.digest] = entry

                next if entry.revision_id == @revision.id
                sitemap_up_to_now_exclusive_digests << entry.digest
            end
        end

        {
            site:                data[:site],
            scans:               data[:scans],
            revisions:           data[:revisions],
            sitemap:             data[:sitemap],
            sitemap_current_digests:     sitemap_current_digests,
            sitemap_up_to_now_inclusive: sitemap_up_to_now_inclusive,
            sitemap_up_to_now_exclusive_digests: sitemap_up_to_now_exclusive_digests,
            sitemap_with_issues: sitemap_with_issues,
            states:              states,
            severities:          severities,
            sitemap_data:        sitemap_data,
            max_severity:        max_severity,
            issues:              page_filtered_issues,
            chart_data:          chart_data,
            scan_data:           scan_data,
            revision_data:       revision_data,
            unique_issues_count: unique_issues_count.size
        }
    end

    def update_sitemap_data( data, issue )
        data[issue.vector.action] ||= {
            internal:     sitemap_entry_url( issue.vector.sitemap_entry.digest ),

            # Issues are sorted by severity first, the first one will be the max.
            max_severity: issue.severity.to_s,
            digest:       issue.vector.sitemap_entry.digest,
            issue_count:  0,
            seen:         Set.new
        }

        return if data[issue.vector.action][:seen].include? issue.digest
        data[issue.vector.action][:seen] << issue.digest

        data[issue.vector.action][:issue_count] += 1
    end

    def update_chart_data( data, issue )
        if data.empty?
            data.merge!(
                issue_names:              {},
                severities:               {},
                severity_index_for_issue: {},
                severity_regions:         {},
                seen:                     Set.new,
                total_issues:             0
            )
        end

        if filter_pages? && !page_id_in_filter?( issue.vector.sitemap_entry.digest )
            return
        end

        return if data[:seen].include?( issue.digest )
        data[:seen] << issue.digest

        data[:total_issues] += 1

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
                issue_type_severities: {
                    name: params[:filter][:severities]
                }
            )
        else
            issues.where(
                issue_type_severities: {
                    name: params[:filter][:severities]
                }
            )
        end
    end

    def filter_pages?
        prepare_issue_filters
        params[:filter][:pages].any?
    end

    def page_id_in_filter?( page_id )
        prepare_issue_filters
        params[:filter][:pages].include? page_id.to_s
    end

    def filter_pages( issues )
        return issues if !filter_pages?

        # TODO: This is broken.
        issues.joins(:page).where(
            'issues.sitemap_entry.digest IN (?) OR issue_pages.sitemap_entry.digest IN (?)',
            params[:filter][:pages], params[:filter][:pages]
        )
    end

    def preload_issue_associations( issues )
        issues.includes(:site).includes(:scan).
            includes( revision: { scan: [:profile, :schedule] } ).
            includes(:reviewed_by_revision).
            includes(:type).includes(:severity).
            includes(:vector).includes( vector: :sitemap_entry ).
            includes( page: :sitemap_entry ).
            includes( siblings: :revision ).
            includes( siblings: :scan )
    end

    def prepare_issue_filters
        params[:filter]              ||= {}
        params[:filter][:type]       ||= 'include'
        params[:filter][:pages]      ||= []

        if params[:filter][:type] == 'include'
            params[:filter][:states]     ||= %w(trusted)
            params[:filter][:severities] ||=
                IssueTypeSeverity::SEVERITIES.map(&:to_s) - ['informational']
        else
            params[:filter][:states]     ||= []
            params[:filter][:severities] ||= []
        end
    end

end
