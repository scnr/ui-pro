require 'active_support/concern'

module ProfileAttributes
    extend ActiveSupport::Concern

    included do
        validate :validate_scope_redundant_path_patterns
        validate :validate_http_cookies
        validate :validate_http_request_headers
        validate :validate_session_check
        validate :validate_checks
        validate :validate_platforms
        validate :validate_audit_link_templates
        validate :validate_scope_url_rewrites

        serialize :plugins, Hash
        serialize :http_cookies,                   Hash
        serialize :http_request_headers,           Hash
        serialize :scope_exclude_path_patterns,    Array
        serialize :scope_exclude_content_patterns, Array
        serialize :scope_include_path_patterns,    Array
        serialize :scope_extend_paths,             Array
        serialize :scope_restrict_paths,           Array
        serialize :scope_redundant_path_patterns,  Hash
        serialize :scope_url_rewrites,             Hash
        serialize :audit_exclude_vector_patterns,  Array
        serialize :audit_include_vector_patterns,  Array
        serialize :audit_link_templates,           Array
        serialize :checks,                         Array
        serialize :platforms,                      Array
        serialize :input_values,                   Hash
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
    end

    %w(scope_exclude_path_patterns scope_exclude_content_patterns
        scope_include_path_patterns scope_restrict_paths scope_extend_paths
        audit_exclude_vector_patterns audit_include_vector_patterns
        audit_link_templates).each do |m|

        define_method "#{m}=" do |string_or_array|
            super self.class.string_list_to_array( string_or_array )
        end
    end

    %w(scope_redundant_path_patterns scope_url_rewrites).each do |m|
        define_method "#{m}=" do |string_or_hash|
            super self.class.string_list_to_hash( string_or_hash, ':' )
        end
    end

    %w(http_cookies http_request_headers input_values).each do |m|
        define_method "#{m}=" do |string_or_hash|
            super self.class.string_list_to_hash( string_or_hash, '=' )
        end
    end

    %w(checks platforms).each do |m|
        define_method "#{m}=" do |list|
            super list.reject{ |i| i.to_s.empty? }
        end
    end

    def checks_with_info
        checks.inject({}) { |h, n| h[n] = ::FrameworkHelper.checks[n]; h }
    end

    def validate_scope_redundant_path_patterns
        scope_redundant_path_patterns.each do |pattern, counter|
            next if counter.to_i > 0
            errors.add :scope_redundant_path_patterns,
                       "rule '#{pattern}' needs an integer counter greater than 0"
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

        begin
            Regexp.new( session_check_pattern.to_s )
        rescue RegexpError => e
            errors.add :session_check_pattern, "not a valid regular expression (#{e})"
        end
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
            next if !substitution.to_s.strip.empty?

            errors.add :scope_url_rewrites,
                       "substitution for pattern #{pattern} cannot be empty"
            next
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

end
