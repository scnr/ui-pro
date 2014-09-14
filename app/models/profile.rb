class Profile < ActiveRecord::Base

    belongs_to :user
    has_many   :scans
    belongs_to :plan

    DESCRIPTIONS_FILE = "#{Rails.root}/config/profile/attributes.yml"

    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :user

    validates_presence_of   :description

    validate :validate_description
    validate :validate_scope_redundant_path_patterns
    validate :validate_http_cookies
    validate :validate_http_request_headers
    validate :validate_session_check
    validate :validate_checks
    validate :validate_platforms
    validate :validate_audit_link_templates
    validate :validate_scope_url_rewrites

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
    serialize :plugins,                        Hash
    serialize :input_values,                   Hash

    RPC_OPTS = [
        :audit_cookies,
        :audit_cookies_extensively,
        :audit_exclude_vector_patterns,
        :audit_forms,
        :audit_headers,
        :audit_include_vector_patterns,
        :audit_include_vectors,
        :audit_link_templates,
        :audit_links,
        :audit_with_both_http_methods,
        :authorized_by,
        :browser_cluster_ignore_images,
        :browser_cluster_job_timeout,
        :browser_cluster_pool_size,
        :browser_cluster_screen_height,
        :browser_cluster_screen_width,
        :browser_cluster_worker_time_to_live,
        :checks,
        :http_authentication_password,
        :http_authentication_username,
        :http_cookies,
        :http_proxy_host,
        :http_proxy_password,
        :http_proxy_port,
        :http_proxy_type,
        :http_proxy_username,
        :http_request_concurrency,
        :http_request_headers,
        :http_request_queue_size,
        :http_request_redirect_limit,
        :http_request_timeout,
        :http_user_agent,
        :input_values,
        :session_check_pattern,
        :session_check_url,
        :no_fingerprinting,
        :platforms,
        :plugins,
        :scope_auto_redundant_paths,
        :scope_directory_depth_limit,
        :scope_dom_depth_limit,
        :scope_exclude_binaries,
        :scope_exclude_content_patterns,
        :scope_exclude_path_patterns,
        :scope_extend_paths,
        :scope_https_only,
        :scope_include_path_patterns,
        :scope_include_subdomains,
        :scope_page_limit,
        :scope_redundant_path_patterns,
        :scope_restrict_paths,
        :scope_url_rewrites
    ]

    def to_s
        name
    end

    def to_rpc_options
        opts = {}
        attributes.each do |k, v|
            next if !RPC_OPTS.include?( k.to_sym ) || v.nil? ||
                (v.respond_to?( :empty? ) ? v.empty? : false)

            if (group_name = find_group_option( k ))
                group_name = group_name.to_s
                opts[group_name] ||= {}
                opts[group_name][k[group_name.size+1..-1]] = v
            else
                opts[k] = v
            end
        end

        Arachni::Options.hash_to_rpc_data( opts )
    end

    def export( serializer = YAML )
        profile_hash = to_rpc_options
        profile_hash[:name] = name
        profile_hash[:description] = description

        profile_hash = profile_hash.stringify_keys
        if serializer == JSON
            JSON::pretty_generate profile_hash
        else
            serializer.dump profile_hash
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

    def self.import( file )
        serialized = file.read

        data = begin
            JSON.load serialized
        rescue
            YAML.safe_load serialized rescue nil
        end

        return if !data.is_a?( Hash )

        data['name']        ||= file.original_filename
        data['description'] ||= "Imported from '#{file.original_filename}'."

        import_from_data( data )
    end

    def self.import_from_data( data )
        options = {}
        data.each do |name, value|
            if Arachni::Options.group_classes.include?( name.to_sym )
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

        new options
    end

    def self.string_list_to_array( string_or_array )
        case string_or_array
            when Array
                string_or_array
            else
                string_or_array.to_s.split( /[\n\r]/ ).reject(&:empty?)
        end
    end

    def self.string_list_to_hash( string_or_hash, hash_delimiter )
        case string_or_hash
            when Hash
                string_or_hash
            else
                Hash[string_or_hash.to_s.split( /[\n\r]/ ).reject(&:empty?).
                         map{ |rule| rule.split( hash_delimiter, 2 ) }]
        end
    end

    private

    def find_group_option( name )
        Arachni::Options.group_classes.keys.find { |n| name.start_with? "#{n}_" }
    end

    def validate_description
        return if ActionController::Base.helpers.strip_tags( description ) == description
        errors.add :description, 'cannot contain HTML, please use Markdown instead'
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
