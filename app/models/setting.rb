class Setting < ActiveRecord::Base
    include WithCustomSerializer
    include WithEvents
    include WithScannerOptions

    events
    set_scanner_options(
        http_request_timeout:           Integer,
        http_request_queue_size:        Integer,
        http_request_redirect_limit:    Integer,
        http_response_max_size:         Integer,
        http_proxy_host:                String,
        http_proxy_port:                Integer,
        http_proxy_username:            String,
        http_proxy_password:            String,

        browser_cluster_pool_size:              Integer,
        browser_cluster_job_timeout:            Integer,
        browser_cluster_worker_time_to_live:    Integer
    )

    validates :max_parallel_scans, numericality: { greater_than: 0 },
              allow_nil: true
    validate  :validate_max_parallel_scans

    def max_parallel_scans_auto?
        max_parallel_scans.nil?
    end

    def to_scanner_options
        options = super

        %w(proxy_host proxy_port proxy_username proxy_password).each do |proxy|
            next if !options['http'][proxy].blank?
            options['http'][proxy] = nil
        end

        options
    end

    private

    def validate_max_parallel_scans
        return if !max_parallel_scans

        msgs = []

        Site.all.each do |site|
            next if max_parallel_scans >= site.profile.max_parallel_scans

            msgs << "#{site.url} has a limit of #{site.profile.max_parallel_scans}"
        end

        return if msgs.empty?

        errors.add :max_parallel_scans,
                   "cannot be less than any site setting (#{msgs.join(', ')})"
    end
end
