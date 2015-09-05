module ScanResults
    extend ActiveSupport::Concern
    include ScanResultsHelper

    included do
        before_action :set_counters, only: SCAN_RESULT_ACTIONS
    end

    SCAN_RESULT_ACTIONS = [ :issues, :coverage, :reviews, :monitor ]

    def issues
        @issues_summary = prepare_issue_data

        process_and_show
    end

    def coverage
        @coverage = prepare_coverage_data

        process_and_show
    end

    def reviews
        @reviews = prepare_reviews_data

        process_and_show
    end

    def monitor
        @monitor = prepare_monitor_data

        process_and_show
    end

    private

    def set_counters
        @coverage_count = scan_results_coverage.count(:url, :code)
        @reviews_count  = filter_pages(
            scan_results_reviews_owner.reviewed_issues
        ).count
    end

    def scan_results_issues
        # Can't do filtering here, the rest of the interface relies of full
        # data in order to fill in context, like severities, states etc.
        #
        # The filtering will take place in #process_issues.
        scan_results_issues_owner.issues
    end

    def scan_results_coverage
        scan_results_coverage_owner.sitemap_entries.coverage
    end

    def scan_results_reviewed_issues
        # Reviewed issues don't really need further processing not are they
        # used to provide context for other areas, so we can do the filtering
        # here and get it over with.
        filter_pages(
            preload_issue_associations(
                scan_results_reviews_owner.reviewed_issues
            )
        )
    end

    # Starts the global {#process_issues issue processing} using
    # {#scan_results_issues}.
    def perform_issue_processing
        process_issues( scan_results_issues.includes( :sitemap_entry ) )
    end

    def process_and_show
        perform_issue_processing

        render 'show'
    end

    def prepare_coverage_data
        coverage_data( scan_results_coverage )
    end

    def prepare_reviews_data
        { issues: scan_results_reviewed_issues }
    end

    def prepare_issue_data
        fail 'Not implemented'
    end

    def prepare_monitor_data
        fail 'Not implemented'
    end

    def scan_results_owner
        fail 'Not implemented'
    end

    def scan_results_issues_owner
        scan_results_owner
    end

    def scan_results_coverage_owner
        scan_results_owner
    end

    def scan_results_reviews_owner
        scan_results_owner
    end
end
