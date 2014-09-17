class GlobalProfile < ActiveRecord::Base
    include ProfileRpcHelpers
    include GlobalProfileAttributes

    RPC_OPTS = [
        :plugins,
        :scope_auto_redundant_paths,
        :scope_directory_depth_limit,
        :scope_exclude_binaries,
        :scope_include_subdomains,
        :scope_https_only,
        :scope_dom_depth_limit,
        :http_request_concurrency,
        :http_request_redirect_limit,
        :http_request_timeout,
        :http_request_queue_size,
        :http_response_max_size,
        :browser_cluster_pool_size,
        :browser_cluster_job_timeout,
        :browser_cluster_worker_time_to_live,
        :browser_cluster_ignore_images
    ]

    def self.to_rpc_options
        first.to_rpc_options
    end

end
