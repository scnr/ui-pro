module ScanResults
    extend ActiveSupport::Concern
    include ScanResultsHelper
    include RevisionsHelper

    included do
        before_action :set_counters, only: SCAN_RESULT_ACTIONS
    end

    REVERT_MODELS = [ :site_profile, :site_role ]

    DEFAULT_ACTION = :issues

    SCAN_RESULT_SITE_ACTIONS     = [ :issues, :coverage, :reviews, :events, :export ]

    SCAN_RESULT_SCAN_ACTIONS     =
        SCAN_RESULT_SITE_ACTIONS

    SCAN_RESULT_REVISION_ACTIONS =
        SCAN_RESULT_SITE_ACTIONS +
        SCAN_RESULT_SCAN_ACTIONS +
            [ :revert_configuration, :configuration, :summary, :health, :errors ]

    SCAN_RESULT_ACTIONS          = SCAN_RESULT_REVISION_ACTIONS

    SCAN_RESULT_SITE_ACTIONS_PER_CONTROLLER = {
        sites:     SCAN_RESULT_SITE_ACTIONS,
        scans:     SCAN_RESULT_SCAN_ACTIONS,
        revisions: SCAN_RESULT_REVISION_ACTIONS
    }

    def summary
        @summary = prepare_live_stream_data
        process_and_show

        session[:live_last_update] = Time.now
    end

    def prepare_live_stream_data
        {
            issues:   preload_issue_associations( scan_results_owner.issues ),
            coverage: scan_results_coverage,
            reviews:  scan_results_reviewed_issues
        }
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

    def events
        @events = prepare_events_data
        process_and_show
    end

    def configuration
        @configuration = prepare_configuration_data
        process_and_show
    end

    def export
        @report = scan_results_owner.report
        process_and_show
    end

    def report
        report        = scan_results_owner.report
        report_object = SCNR::Engine::Report.load( report.location )

        name = "#{URI( @scan.url ).host} - #{@scan.profile.name} - #{@revision.id}".
          gsub( '/', '_' ).gsub( '.', '_' ).gsub( "\n", '' ).gsub( "\r", '' )

        format = URI( request.url ).path.split( '.' ).last

        if format == 'ser'
            report    = report_object.to_ser
            extension = 'ser'
        else
            report    = FrameworkHelper.framework { |f| f.report_as format, report_object }
            extension = FrameworkHelper.reporters[format][:extension]
        end

        send_data report,
                  type: FrameworkHelper.content_type_for_report( format ),
                  disposition: "attachment; filename=\"#{name}.#{extension}\""
    end

    def revert_configuration
        revert_model = params.permit(:model)[:model].to_sym

        if !REVERT_MODELS.include?( revert_model )
            fail "Cannot revert #{revert_model}"
        end

        @configuration = prepare_configuration_data

        snapshot = @revision.send( revert_model )

        if revert_model == :site_role
            current  = @scan.site_role
        else
            current  = @site.profile
        end

        attributes = snapshot.attributes.dup
        %w(id site_id revision_id created_at updated_at).each do |attribute|
            attributes.delete attribute
        end

        if current.update( attributes )
            redirect_back fallback_location: configuration_revision_path( @revision ),
                          notice: 'Settings were successfully updated.'
        else
            redirect_back fallback_location: configuration_revision_path( @revision ),
                          notice: 'Settings could not be updated.'
        end
    end

    private

    def set_counters
        @coverage_count = scan_results_coverage.count(:url)
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

    def scan_results_events
        scan_results_events_owner.events
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

        if params[:partial]
            render partial: '/shared/scan_results',
                   format: :html
        else
            render 'show'
        end
    end

    def prepare_coverage_data
        coverage_data( scan_results_coverage )
    end

    def prepare_reviews_data
        { issues: scan_results_reviewed_issues }
    end

    def prepare_configuration_data
        {
            snapshot: scan_results_owner.rpc_options,
            current:  @revision ? @revision.scan.rpc_options : nil
        }
    end

    def prepare_events_data
        scan_results_events
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

    def scan_results_events_owner
        scan_results_owner
    end

end
