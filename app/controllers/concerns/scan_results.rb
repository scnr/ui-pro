module ScanResults
    extend ActiveSupport::Concern
    include ScanResultsHelper

    included do
        before_action :set_counters, only: SCAN_RESULT_ACTIONS
    end

    SCAN_RESULT_REVISION_ACTIONS = [ :live, :health, :errors ]
    SCAN_RESULT_ACTIONS          = [ :issues, :coverage, :reviews ] +
        SCAN_RESULT_REVISION_ACTIONS

    def live
        from = nil
        if params[:from]
            from = Time.at( params[:from].to_f / 1000.0 )
        end

        to = nil
        if params[:to]
            to = Time.at( params[:to].to_f / 1000.0 )
        end

        respond_to do |format|
            format.html do
                perform_issue_processing
                render 'show'
            end

            format.js do
                @live = prepare_live_stream_data( from, to )
                render partial: '/shared/scan_results/live/stream', format: :js
            end
        end

        session[:live_last_update] = Time.now
    end

    def prepare_live_stream_data( from, to = Time.now )
        data = {}

        data[:issues] = apply_time_range(
            preload_issue_associations( scan_results_owner.issues ),
            from, to
        )

        data[:coverage] = apply_time_range( scan_results_coverage, from, to )
        data[:reviews] = apply_time_range( scan_results_reviewed_issues, from,
                                           to, :updated_at )

        data
    end

    def apply_time_range( relation, from, to, attribute = :created_at )
        return relation if !from || !to

        # return relation

        relation.where( attribute => (from..to) )
    end

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

    def health
        @health = prepare_health_data

        process_and_show
    end

    def errors
        if @revision.error_messages.blank?
            redirect_to action: :show
            return
        end

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

    def prepare_health_data
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
