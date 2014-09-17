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

    def permitted_attributes
        # Set in the default global profile, override as needed in the User or
        # Site profiles:
        # * plugins                             =>
        #   Used to configure the DB logger, login stuff (like autologin or
        #   custom login plugins for each site), notifier, etc.
        # * authorized_by                       => User e-mail address
        # * audit_headers                       => false
        # * audit_with_both_http_methods        => false
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
        #
        # Set in Plan profile:
        # * scope_page_limit
        [
            :name, :audit_cookies, :audit_forms, :audit_links, :http_user_agent,
            :audit_exclude_vector_patterns, :audit_include_vector_patterns,
            :http_cookies, :http_request_headers, :scope_exclude_path_patterns,
            :scope_exclude_vectors, :scope_extend_paths, :scope_include_subdomains,
            :scope_include_path_patterns, :scope_page_limit, :session_check_pattern,
            :session_check_url, { checks: [] }, :scope_redundant_path_patterns,
            :scope_restrict_paths, :description, :scope_exclude_content_patterns,
            :no_fingerprinting, { platforms: [] }, :http_authentication_username,
            :http_authentication_password, :input_values, :browser_cluster_screen_width,
            :browser_cluster_screen_height, :audit_link_templates, :scope_url_rewrites
        ]
    end
end
