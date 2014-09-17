class GlobalProfilePolicy < ApplicationPolicy

    def permitted_attributes
        # * plugins                             =>
        #   Used to configure the DB logger, login stuff (like autologin or
        #   custom login plugins for each site), notifier, etc.
        # * scope_auto_redundant_paths          => 10
        # * scope_directory_depth_limit         => 10
        # * scope_exclude_binaries              => true
        # * scope_include_subdomains            => false
        # * scope_https_only                    => false
        # * scope_dom_depth_limit               => 10
        # * http_response_max_size              => 200_000
        # * http_request_concurrency            => 10
        # * http_request_redirect_limit         => 5
        # * http_request_timeout                => 5_000
        # * http_request_queue_size             => 1_000?
        # * browser_cluster_pool_size           => 10?
        # * browser_cluster_job_timeout         => 5_000
        # * browser_cluster_worker_time_to_live => 100
        # * browser_cluster_ignore_images       => true
        [
            :scope_auto_redundant_paths, :scope_directory_depth_limit,
            :scope_exclude_binaries, :scope_include_subdomains,
            :scope_https_only, :scope_dom_depth_limit, :http_request_concurrency,
            :http_request_redirect_limit, :http_request_timeout,
            :http_request_queue_size, :browser_cluster_pool_size,
            :browser_cluster_job_timeout, :browser_cluster_worker_time_to_live,
            :browser_cluster_ignore_images, { plugins: {} }, :http_response_max_size
        ]
    end
end
