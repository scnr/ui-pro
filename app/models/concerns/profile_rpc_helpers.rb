require 'active_support/concern'

module ProfileRpcHelpers
    extend ActiveSupport::Concern

    TEMPLATE_PATH_PATTERN_COUNTER = 1

    RPC_OPTS = [
        :plugins,

        :checks,

        :platforms,

        :no_fingerprinting,

        :input_values,

        :audit_cookies,
        :audit_exclude_vector_patterns,
        :audit_forms,
        :audit_include_vector_patterns,
        :audit_link_templates,
        :audit_links,
        :audit_xmls,
        :audit_jsons,
        :audit_ui_forms,
        :audit_ui_inputs,
        :audit_parameter_values,

        :browser_cluster_wait_for_elements,
        :browser_cluster_pool_size,
        :browser_cluster_job_timeout,
        :browser_cluster_worker_time_to_live,

        :http_authentication_password,
        :http_authentication_username,
        :http_cookies,
        :http_request_headers,
        :http_request_queue_size,
        :http_request_concurrency,
        :http_request_redirect_limit,
        :http_request_timeout,

        :scope_exclude_file_extensions,
        :scope_page_limit,
        :scope_exclude_content_patterns,
        :scope_exclude_path_patterns,
        :scope_extend_paths,
        :scope_include_path_patterns,
        :scope_restrict_paths,
        :scope_url_rewrites,
        :scope_dom_depth_limit,
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

        :session_check_pattern,
        :session_check_url,

        :device_height,
        :device_width,
        :device_user_agent,
        :device_touch,
        :device_pixel_ratio
    ]

    module ClassMethods
        def flatten( data )
            options = {}
            data.each do |name, value|
                if SCNR::Engine::Options.group_classes.include?( name.to_sym )
                    value.each do |k, v|
                        key = "#{name}_#{k}"
                        next if !attribute_names.include?( key.to_s )

                        options[key] = v
                    end
                else
                    next if !attribute_names.include?( name.to_s )
                    options[name] = value
                end
            end

            options
        end
    end

    def to_rpc_options
        opts = {}
        attributes.each do |k, v|
            next if !self.class::RPC_OPTS.include?( k.to_sym )

            if (group_name = find_group_option( k ))
                group_name = group_name.to_s
                opts[group_name] ||= {}
                opts[group_name][k[group_name.size+1..-1]] = v
            else
                opts[k] = v
            end
        end

        if has_option?( :scope_template_path_patterns )
            opts['scope']['redundant_path_patterns'] =
                scope_template_path_patterns.
                    inject({}) { |h, pattern| h[pattern] = TEMPLATE_PATH_PATTERN_COUNTER; h }
        end

        if has_option?( :http_authentication_username ) ||
            has_option?( :http_authentication_password )

            %w(authentication_username authentication_password).each do |k|
                next if !opts['http'][k].blank?

                opts['http'].delete k
            end
        end

        opts['plugins'] ||= {}

        FrameworkHelper.default_plugins.each do |name|
            opts['plugins'][name.to_s] = {}
        end

        opts
    end

    def find_group_option( name )
        SCNR::Engine::Options.group_classes.keys.find { |n| name.start_with? "#{n}_" }
    end
end
