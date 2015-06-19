require 'active_support/concern'

module ProfileAttributes
    extend ActiveSupport::Concern

    included do
        [
            :checks,

            :platforms,

            :plugins,

            :http_cookies,
            :http_request_headers,

            :scope_url_rewrites,
            :scope_redundant_path_patterns,
            :scope_exclude_path_patterns,
            :scope_exclude_content_patterns,
            :scope_include_path_patterns,
            # :scope_restrict_paths,
            # :scope_extend_paths,

            :audit_exclude_vector_patterns,
            :audit_include_vector_patterns,
            :audit_link_templates,

            :input_values,

            :browser_cluster_wait_for_elements
        ].each do |attr|
            next if !has_option?( attr )

            validate "validate_#{attr}"
        end

        if has_option?( :plugins )
            validate :validate_plugin_options
        end

        if has_option?( :session_check_url ) &&
            has_option?( :session_check_pattern )
            validate :validate_session_check
        end

        {
            plugins:                        Hash,
            checks:                         Array,
            platforms:                      Array,
            input_values:                   Hash,

            http_cookies:                   Hash,
            http_request_headers:           Hash,
    
            scope_exclude_path_patterns:    Array,
            scope_exclude_content_patterns: Array,
            scope_include_path_patterns:    Array,
            scope_extend_paths:             Array,
            scope_restrict_paths:           Array,
            scope_redundant_path_patterns:  Hash,
            scope_url_rewrites:             Hash,
    
            audit_exclude_vector_patterns:  Array,
            audit_include_vector_patterns:  Array,
            audit_link_templates:           Array,

            browser_cluster_wait_for_elements: Hash
        }.each do |attr, type|
            next if !has_option?( attr )

            serialize attr, type
        end

        %w(scope_restrict_paths scope_extend_paths).each do |m|
            next if !has_option?( m )

            define_method "#{m}=" do |string_or_array|
                super self.class.string_list_to_array( string_or_array )
            end
        end

        if has_option?( :audit_link_templates )
            def audit_link_templates=( string_or_array )
                super self.class.string_list_to_array( string_or_array )
            end
        end

        %w(
            scope_exclude_path_patterns
            scope_exclude_content_patterns
            scope_include_path_patterns
            audit_exclude_vector_patterns
            audit_include_vector_patterns
        ).each do |m|
            next if !has_option?( m )

            define_method "#{m}=" do |string_or_array|
                super self.class.string_list_to_array( string_or_array )
            end

            define_method "validate_#{m}" do
                check_patterns send(m), m.to_sym
            end
        end

        %w(scope_redundant_path_patterns scope_url_rewrites
            browser_cluster_wait_for_elements).each do |m|
            next if !has_option?( m )

            define_method "#{m}=" do |string_or_hash|
                super self.class.string_list_to_hash( string_or_hash, ':' )
            end
        end

        %w(http_cookies http_request_headers input_values).each do |m|
            next if !has_option?( m )

            define_method "#{m}=" do |string_or_hash|
                super self.class.string_list_to_hash( string_or_hash, '=' )
            end
        end

        %w(checks platforms).each do |m|
            next if !has_option?( m )

            define_method "#{m}=" do |list|
                super list.reject{ |i| i.to_s.empty? }
            end
        end
    end

    module ClassMethods
        def string_list_to_array( string_or_array )
            case string_or_array
                when Array
                    string_or_array
                else
                    string_or_array.to_s.split( /[\n\r]/ ).reject(&:empty?)
            end
        end

        def string_list_to_hash( string_or_hash, hash_delimiter )
            case string_or_hash
                when Hash
                    string_or_hash
                else
                    Hash[string_or_hash.to_s.split( /[\n\r]/ ).reject(&:empty?).
                             map{ |rule| rule.split( hash_delimiter, 2 ) }]
            end
        end

        def has_option?( option )
            column_names.include? option.to_s
        end
    end

    def has_option?( *args )
        self.class.has_option?( *args )
    end

    def checks_with_info
        checks.inject({}) { |h, n| h[n] = ::FrameworkHelper.checks[n]; h }
    end

    def plugins_with_info
        plugins.keys.inject({}) { |h, n| h[n] = ::FrameworkHelper.plugins[n]; h }
    end

    def validate_input_values
        input_values.each do |pattern, _|
            if pattern.empty?
                errors.add :input_values, 'pattern cannot be empty'
            end

            check_pattern( pattern, :input_values )
        end
    end

    def validate_scope_redundant_path_patterns
        scope_redundant_path_patterns.each do |pattern, counter|
            if pattern.empty?
                errors.add :scope_redundant_path_patterns, 'pattern cannot be empty'
            end

            check_pattern( pattern, :scope_redundant_path_patterns )

            if counter.to_i <= 0
                errors.add :scope_redundant_path_patterns,
                           "rule '#{pattern}' needs an integer counter greater than 0"
            end
        end
    end

    def validate_browser_cluster_wait_for_elements
        browser_cluster_wait_for_elements.each do |pattern, css|
            if pattern.empty?
                errors.add :browser_cluster_wait_for_elements, 'pattern cannot be empty'
            end

            check_pattern( pattern, :browser_cluster_wait_for_elements )

            if css.to_s.strip.empty?
                errors.add :browser_cluster_wait_for_elements,
                           "rule '#{pattern}' is missing a CSS selector"
            end
        end
    end

    def validate_http_cookies
        http_cookies.each do |name, value|
            next if !name.strip.empty?
            errors.add :http_cookies, "name cannot be blank ('#{name}=#{value}')"
        end
    end

    def validate_http_request_headers
        http_request_headers.each do |name, value|
            next if !name.strip.empty?
            errors.add :http_request_headers, "name cannot be blank ('#{name}=#{value}')"
        end
    end

    def validate_session_check
        return if session_check_url.to_s.empty? && session_check_pattern.to_s.empty?

        if (url = Arachni::URI( session_check_url )).to_s.empty? || !url.absolute?
            errors.add :session_check_url, 'not a valid absolute URL'
        end

        errors.add :session_check_pattern, 'cannot be blank' if session_check_pattern.to_s.empty?

        check_pattern( session_check_pattern, :session_check_pattern )
    end

    def validate_audit_link_templates
        audit_link_templates.each do |pattern|
            begin
                regexp = Regexp.new( pattern )
                next if regexp.names.any?

                errors.add :audit_link_templates, "#{pattern} has no named captures"
            rescue RegexpError => e
                errors.add :audit_link_templates, "invalid pattern #{pattern} (#{e})"
                next
            end
        end
    end

    def validate_scope_url_rewrites
        scope_url_rewrites.each do |pattern, substitution|
            pattern      = pattern.to_s.strip
            substitution = substitution.to_s.strip

            if pattern.empty?
                errors.add :scope_url_rewrites, 'pattern cannot be empty'
                next
            end

            if substitution.empty?
                errors.add :scope_url_rewrites,
                           "substitution for pattern #{pattern} cannot be empty"
                next
            end

            next if !check_pattern( pattern, :scope_url_rewrites )

            if !(pattern =~ /\(.*\)/)
                errors.add :scope_url_rewrites,
                           "pattern #{pattern} includes no captures"
            end

            if !(substitution =~ /\\\d/)
                errors.add :scope_url_rewrites,
                           "substitution #{substitution} includes no substitutions"
            end
        end
    end

    def validate_checks
        available = ::FrameworkHelper.checks.keys.map( &:to_s )
        checks.each do |check|
            next if available.include? check.to_s
            errors.add :checks, "'#{check}' does not exist"
        end
    end

    def validate_platforms
        available = ::FrameworkHelper.platform_shortnames.map(&:to_s)
        platforms.each do |platform|
            next if available.include? platform.to_s
            errors.add :platforms, "'#{platform}' does not exist"
        end
    end

    def validate_plugins
        available = ::FrameworkHelper.plugins.keys.map( &:to_s )
        plugins.keys.each do |plugin|
            next if available.include? plugin.to_s
            errors.add :plugins, "'#{plugin}' does not exist"
        end
    end

    def validate_plugin_options
        available = ::FrameworkHelper.plugins.keys.map( &:to_s )
        ::FrameworkHelper.framework do |f|
            plugins.each do |plugin, options|
                next if !available.include? plugin.to_s

                begin
                    f.plugins.prepare_options( plugin, f.plugins[plugin],
                                               (options || {}).reject { |k, v| v.empty? }
                    )
                rescue Arachni::Component::Options::Error::Invalid => e
                    errors.add :plugins, e.to_s
                end
            end
        end
    end

    def check_patterns( patterns, attribute )
        patterns.each do |pattern|
            check_pattern( pattern, attribute )
        end
    end

    def check_pattern( pattern, attribute )
        Regexp.new( pattern.to_s )
        true
    rescue RegexpError => e
        errors.add attribute, "invalid pattern #{pattern.inspect} (#{e})"
        false
    end

end
