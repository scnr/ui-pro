class ProfilePolicy < ApplicationPolicy
    alias :profile :record

    class Scope < Scope
        def non_admin_resolve
            scope.where( user: user )
        end
    end

    allow_authenticated :index, :create, :copy

    allow_admin_or :show do |user, profile|
        profile.user == user
    end

    allow_admin_or :update, :destroy do |user, profile|
        # Don't allow profiles to be manipulated if they have associated scans.
        profile.user == user && profile.scans.with_revisions.empty?
    end

    # TODO: Whitelist checks and plugins.
    def permitted_attributes
        [
            :name, :audit_cookies, :audit_cookies_extensively, :audit_forms,
            :audit_headers, :audit_links, :authorized_by, :scope_auto_redundant_paths,
            :audit_exclude_vector_patterns, :audit_include_vector_patterns,
            :http_cookies, :http_request_headers, :scope_directory_depth_limit,
            :scope_exclude_path_patterns, :scope_exclude_path_patterns_binaries,
            :scope_exclude_path_patterns_cookies, :scope_exclude_path_patterns_vectors,
            :scope_extend_paths, :scope_include_subdomains, :audit_with_both_http_methods,
            :http_request_concurrency, :scope_include_path_patterns, :scope_page_limit,
            :login_check_pattern, :login_check_url, :spawns, :min_pages_per_instance,
            { checks: [] }, :http_proxy_host, :http_proxy_password, :http_proxy_port,
            :http_proxy_type, :http_proxy_username, :http_request_redirect_limit,
            :scope_redundant_path_patterns, :scope_restrict_paths, :http_user_agent,
            :http_request_timeout, :description, :scope_https_only,
            :scope_exclude_path_patterns_pages, :no_fingerprinting, { platforms: [] },
            :http_authentication_username, :http_authentication_password,
            :input_values, :browser_cluster_pool_size, :browser_cluster_job_timeout,
            :browser_cluster_worker_time_to_live, :browser_cluster_ignore_images,
            :browser_cluster_screen_width, :browser_cluster_screen_height,
            :scope_dom_depth_limit, :audit_link_templates
        ]
    end
end
