module ScanResultsHelper

    FILTER_KEY    = :filter
    VALID_FILTERS = Set.new(%w(type pages states severities))

    def process_issue_blocks
        @process_issue_blocks ||= []
    end
    def process_issue_blocks_call( issue )
        process_issue_blocks.each do |block|
            block.call issue
        end
    end
    def process_issue( &block )
        process_issue_blocks << block
    end

    def process_issues_after_revision_before_page_filter_blocks
        @process_issues_after_revision_before_page_filter_blocks ||= []
    end
    def process_issues_after_revision_before_page_filter_blocks_call( issue )
        process_issues_after_revision_before_page_filter_blocks.each do |block|
            block.call issue
        end
    end
    def process_issues_after_revision_before_page_filter( &block )
        process_issues_after_revision_before_page_filter_blocks << block
    end

    def process_issues_after_page_filter_blocks
        @process_issues_with_page_filter_blocks ||= []
    end
    def process_issues_after_page_filter_blocks_call( issue )
        process_issues_after_page_filter_blocks.each do |block|
            block.call issue
        end
    end
    def process_issues_after_page_filter( &block )
        process_issues_after_page_filter_blocks << block
    end

    def process_issues_selected_blocks
        @process_issues_selected_blocks ||= []
    end
    def process_issues_selected_blocks_call( issue )
        process_issues_selected_blocks.each do |block|
            block.call issue
        end
    end
    def process_issues_selected( &block )
        process_issues_selected_blocks << block
    end

    def process_issues_done_blocks
        @process_issues_done_blocks ||= []
    end
    def process_issues_done_blocks_call
        process_issues_done_blocks.each do |block|
            block.call
        end
    end
    def process_issues_done( &block )
        process_issues_done_blocks << block
    end

    def process_issues( issues, filters = {} )
        filter_by_revision = filters.include?(:by_revision) ?
            filters[:by_revision] : true

        filter_by_state_and_severity = filters.include?(:by_state_and_severity) ?
            filters[:by_state_and_severity] : true

        issues_count = issues.count
        issues       = preload_issue_associations( issues )

        if filter_pages?
            @sitemap_entry =
                @site.sitemap_entries.
                    where( digest: active_filters[:pages].first ).first
        end

        if filter_by_state_and_severity
            issues = filter_issues_by_severity_and_state( issues )
        end

        scoped_find_each( issues, size: issues_count ) do |issue|
            process_issue_blocks_call( issue )

            if !(filter_by_revision && @revision && @revision.id != issue.revision.id)
                process_issues_after_revision_before_page_filter_blocks_call( issue )
            end

            next if filter_pages? &&
                @sitemap_entry.digest != issue.sitemap_entry.digest

            process_issues_after_page_filter_blocks_call( issue )

            next if filter_by_revision && @revision &&
                @revision.id != issue.revision.id

            process_issues_selected_blocks_call( issue )
        end

        process_issues_done_blocks_call
    end

    def issues_summary_data( data )
        store = {}

        if !data[:scans].is_a?( Array )
            data[:scans] = data[:scans].includes(:revisions).
                includes(:schedule).includes(:profile)
        end

        issues = data[:issues]

        # This needs to happen here, we want this for filtering feedback and
        # thus has to refer to the big, pre-filtering picture.
        if @revision
            states     = issues.where( revision: @revision ).count_states
            severities = issues.where( revision: @revision ).count_severities
        else
            states     = issues.count_states
            severities = issues.count_severities
        end

        sitemap_with_issues  = {}
        chart_data           = {}
        pre_page_filter_data = {}
        revision_data        = {}
        unique_issues_count  = Set.new

        page_filtered_issues = []
        max_severity         = nil

        pre_page_filter_data[:count] = 0

        process_issue do |issue|
            pre_page_filter_data[:count]         += 1
            pre_page_filter_data[:max_severity] ||= issue.severity.to_s
        end

        process_issues_after_revision_before_page_filter do |issue|
            update_chart_data( chart_data, issue )
            update_sitemap_data( sitemap_with_issues, issue )
        end

        # If we're filtering by page, also filter out scans and revisions which
        # haven't logged issues for it.
        if filter_pages?
            data[:scans]     = Set.new
            data[:revisions] = Set.new
        end

        process_issues_after_page_filter do |issue|
            if filter_pages?
                data[:scans]     << issue.scan
                data[:revisions] << issue.revision
            end

            unique_issues_count << issue.digest

            #... because we at least want to grab the filtered max severity now...
            max_severity ||= issue.severity.to_s

            revision_data[issue.revision_id] ||= {}
            revision_data[issue.revision_id][:max_severity] ||= issue.severity.to_s

            revision_data[issue.revision_id][:issue_count] ||= 0
            revision_data[issue.revision_id][:issue_count]  += 1
        end

        process_issues_selected do |issue|
            if pre_page_filter_data[:count] > ApplicationHelper::SCOPED_FIND_EACH_BATCH_SIZE
                next
            end

            page_filtered_issues << issue
        end

        process_issues_done do
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

                sitemap_with_issues = Hash[sitemap_with_issues.sort_by { |url, _| url.size }]
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

            missing_issues = nil
            if @revision && @scan.completed?
                missing_issues = filter_pages( @revision.missing_issues )
            end

            store.merge!(
                site:                data[:site],
                scans:               data[:scans],
                revisions:           data[:revisions],
                sitemap:             data[:sitemap],
                sitemap_with_issues: sitemap_with_issues,
                states:              states,
                severities:          severities,
                sitemap_data:        sitemap_data,
                max_severity:        max_severity,
                issues:              page_filtered_issues,
                missing_issues:      missing_issues,
                chart_data:          chart_data,
                revision_data:       revision_data,
                unique_issues_count: unique_issues_count.size
            )
        end

        store
    end

    def coverage_data( coverage )
        current_digests             = Set.new
        up_to_now_exclusive_digests = Set.new
        up_to_now_inclusive         = {}

        if @revision && @revision.index > 1
            current_digests.merge coverage.reorder('').pluck(:digest)

            SitemapEntry.coverage.where(
                revision: @scan.revisions.reorder( id: :asc )[0..(@revision.index-1)]
            ).each do |entry|
                up_to_now_inclusive[entry.digest] = entry

                next if entry.revision_id == @revision.id
                up_to_now_exclusive_digests << entry.digest
            end
        end

        {
            coverage:                    coverage,
            current_digests:             current_digests,
            up_to_now_inclusive:         up_to_now_inclusive,
            up_to_now_exclusive_digests: up_to_now_exclusive_digests,
        }
    end

    def update_sitemap_data( data, issue )
        data[issue.input_vector.action] ||= {
            internal:     sitemap_entry_url( issue.sitemap_entry.digest ),

            # Issues are sorted by severity first, the first one will be the max.
            max_severity: issue.severity.to_s,
            digest:       issue.sitemap_entry.digest,
            issue_count:  0,
            seen:         Set.new
        }

        return if data[issue.input_vector.action][:seen].include? issue.digest
        data[issue.input_vector.action][:seen] << issue.digest

        data[issue.input_vector.action][:issue_count] += 1
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

        if filter_pages? && !page_id_in_filter?( issue.sitemap_entry.digest )
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

    def link_to_with_filters( *args, &block )
        name, resource, options = *args

        if name.is_a? ActiveRecord::Base
            options = resource
            resource = name
            name     = nil
        end

        options ||= {}

        route = {
            controller: resource.class.name.tableize,
            params:     filter_params
        }

        if ScanResults::SCAN_RESULT_ACTIONS.include?( params[:action].try(:to_sym) )
             route[:action] = params.permit(:action)[:action]
        else
            route[:action] = options[:action] || 'issues'
        end

        ScanResults::SCAN_RESULT_SITE_ACTIONS_PER_CONTROLLER.each do |controller, actions|
            # If the controller doesn't support the current action revert to
            # the default.
            if route[:controller].to_sym == controller &&
                !actions.include?( route[:action].to_sym )
                route[:action] = ScanResults::DEFAULT_ACTION
            end

            parent = controller.to_s.singularize
            if resource.respond_to?( parent )
                route["#{parent}_id"] = resource.send( "#{parent}_id" )
            end
        end

        route['id'] = resource.id

        link_to *[name, route, options].compact, &block
    end

    def filter_params
        { FILTER_KEY => active_filters }
    end

    def filter_params_without_page
        { FILTER_KEY => active_filters.merge( pages: [] ) }
    end

    def filter_issues_by_severity_and_state( issues )
        filter_severities( filter_states( issues ) )
    end

    def filter_states( issues )
        return issues if active_filters[:states].empty?

        if active_filters[:type] == 'exclude'
            issues.where.not( state: active_filters[:states] )
        else
            issues.where( state: active_filters[:states] )
        end
    end

    def filter_severities( issues )
        return issues if active_filters[:severities].empty?

        if active_filters[:type] == 'exclude'
            issues.where.not(
                issue_type_severities: {
                    name: active_filters[:severities]
                }
            )
        else
            issues.where(
                issue_type_severities: {
                    name: active_filters[:severities]
                }
            )
        end
    end

    def filter_pages?
        active_filters[:pages].any?
    end

    def page_id_in_filter?( page_id )
        active_filters[:pages].include? page_id.to_s
    end

    def filter_pages( issues )
        return issues if !filter_pages?

        issues.includes( :sitemap_entry ).
            where( 'sitemap_entries.digest IN (?)', active_filters[:pages] )
    end

    def preload_issue_associations( issues )
        issues.
            includes( :scan ).
            includes( :type ).
            includes( :input_vector ).
            includes( :severity ).
            includes( :sitemap_entry ).
            includes( revision: { scan: [:profile] } ).
            includes( :reviewed_by_revision ).
            includes( page: :sitemap_entry ).
            includes( siblings: :revision ).
            includes( siblings: :scan )
    end

    def active_filters
        return @active_filters if @active_filters

        if params[FILTER_KEY]
            @active_filters =
                params.extract!(FILTER_KEY)[FILTER_KEY].to_unsafe_h.
                    select { |f| VALID_FILTERS.include? f }
        else
            @active_filters = {}
        end

        @active_filters[:type]  ||= 'include'
        @active_filters[:pages] ||= []

        if @active_filters[:type] == 'include'
            @active_filters[:states]     ||= %w(trusted)
            @active_filters[:severities] ||=
                IssueTypeSeverity::SEVERITIES.map(&:to_s) - ['informational']
        else
            @active_filters[:states]     ||= []
            @active_filters[:severities] ||= []
        end

        @active_filters
    end

end
