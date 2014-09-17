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
        [
            :name,
            :description,
            { checks:    [] },
            { platforms: [] },
            :no_fingerprinting,
            :input_values,
            :audit_links,
            :audit_forms,
            :audit_cookies,
            # :audit_headers,
            :audit_link_templates,
            # :audit_with_both_http_methods,
            :audit_exclude_vector_patterns,
            :audit_include_vector_patterns,
            :http_user_agent,
            :http_cookies,
            :http_request_headers,
            :scope_page_limit,
            :scope_extend_paths,
            :scope_restrict_paths,
            :scope_include_path_patterns,
            :scope_exclude_path_patterns,
            :scope_redundant_path_patterns,
            :scope_exclude_content_patterns,
            :scope_exclude_vector_patterns,
            :scope_include_vector_patterns,
            :scope_include_subdomains,
            :scope_url_rewrites,
            :session_check_pattern,
            :session_check_url,
            :http_authentication_username,
            :http_authentication_password,
            :browser_cluster_screen_width,
            :browser_cluster_screen_height
        ]
    end
end
