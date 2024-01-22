class PerformanceSnapshot < ActiveRecord::Base

    STATES = %i(excellent good fair poor)

    MAX_HTTP_TIME_OUT_RATIO               = 0.05
    MAX_HTTP_FAILED_RATIO                 = 0.05
    MAX_HTTP_AVERAGE_RESPONSES_PER_SECOND = 100
    MAX_HTTP_AVERAGE_RESPONSE_TIME        = 2
    MAX_TOTAL_AVERAGE_APP_TIME            = 1.5

    MAX_BROWSER_FAILED_RATIO              = 0.05

    MIN_MAX_CONCURRENCY                   = 1

    belongs_to :revision, class_name: 'Revision', foreign_key: :revision_current_id, optional: true

    def download_kbps
        (download_bps * 8 / 1000).round(2)
    end

    def upload_kbps
        (upload_bps * 8 / 1000).round(2)
    end

    def browser_failed_job_count_state
        self.class.determine_state(
          browser_job_failed_count_pct,
          max_browser_job_failed_count,
          better: :low
        )
    end

    def max_browser_job_failed_count
        (100 * MAX_BROWSER_FAILED_RATIO).to_i
    end

    def browser_job_failed_count_pct
        (browser_job_failed_count / Float( browser_job_count ) * 100).round( 2 )
    end

    def http_time_out_count_state
        self.class.determine_state(
            http_time_out_count_pct,
            max_http_time_out_count,
            better: :low
        )
    end

    def max_http_time_out_count
        (100 * MAX_HTTP_TIME_OUT_RATIO).to_i
    end

    def http_time_out_count_pct
        (http_time_out_count / Float( http_request_count ) * 100).round( 2 )
    end

    def http_failed_count_state
        self.class.determine_state(
          http_failed_count_pct,
          max_http_failed_count,
          better: :low
        )
    end

    def max_http_failed_count
        (100 * MAX_HTTP_FAILED_RATIO).to_i
    end

    def http_failed_count_pct
        (http_failed_count / Float( http_request_count ) * 100).round( 2 )
    end

    def total_average_app_time_state
        self.class.determine_state total_average_app_time, MAX_TOTAL_AVERAGE_APP_TIME, better: :low
    end

    def http_average_responses_per_second_state
        self.class.determine_state http_average_responses_per_second, MAX_HTTP_AVERAGE_RESPONSES_PER_SECOND
    end

    def http_max_concurrency_state
        self.class.determine_state http_max_concurrency, http_original_max_concurrency
    end

    def http_average_response_time_state
        self.class.determine_state http_average_response_time, MAX_HTTP_AVERAGE_RESPONSE_TIME, better: :low
    end

    def self.determine_state( value, max, min: 0.0, better: :high )
        states = STATES
        states = states.reverse if better == :high

        max  = Float( max )
        min  = Float( min )
        max -= min

        step = max / STATES.size

        states.each.with_index do |state, i|
            next if value >= step * (i+1)
            return state
        end

        states.last
    end

    def self.create_from_engine( statistics )
        create( engine_to_attributes( statistics ) )
    end

    def self.engine_to_attributes( statistics )
        {
            http_request_count:                statistics[:http][:request_count],
            http_response_count:               statistics[:http][:response_count],
            http_time_out_count:               statistics[:http][:time_out_count],
            http_failed_count:                 statistics[:http][:failed_count],
            http_average_responses_per_second: statistics[:http][:total_responses_per_second],
            http_average_response_time:        statistics[:http][:total_average_response_time],
            http_max_concurrency:              statistics[:http][:max_concurrency],
            http_original_max_concurrency:     statistics[:http][:original_max_concurrency],
            download_bps:                      statistics[:http][:download_bps],
            upload_bps:                        statistics[:http][:upload_bps],
            total_average_app_time:            statistics[:http][:total_average_app_time],
            browser_job_count:                 statistics[:browser_pool][:completed_job_count],
            browser_job_time_out_count:        statistics[:browser_pool][:time_out_count],
            browser_job_failed_count:          statistics[:browser_pool][:failed_count],
            seconds_per_browser_job:           statistics[:browser_pool][:seconds_per_job],
            runtime:                           statistics[:runtime],
            page_count:                        statistics[:found_pages],
            current_page:                      statistics[:current_page]
        }
    end
end
