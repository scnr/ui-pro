class Profile < ActiveRecord::Base
    include ProfileRpcHelpers
    include ProfileAttributes

    belongs_to :user
    has_many   :scans

    DESCRIPTIONS_FILE = "#{Rails.root}/config/profile/attributes.yml"

    validates_presence_of   :description
    validate :validate_description

    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :user

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
        :audit_parameter_values,
        :browser_cluster_screen_height,
        :browser_cluster_screen_width,
        :http_authentication_password,
        :http_authentication_username,
        :http_cookies,
        :http_request_headers,
        :http_user_agent,
        :http_request_queue_size,
        :http_request_concurrency,
        :http_request_redirect_limit,
        :http_request_timeout,
        :session_check_pattern,
        :session_check_url,
        :scope_exclude_content_patterns,
        :scope_exclude_path_patterns,
        :scope_extend_paths,
        :scope_include_path_patterns,
        :scope_redundant_path_patterns,
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
        :browser_cluster_pool_size,
        :browser_cluster_job_timeout,
        :browser_cluster_worker_time_to_live,
        :browser_cluster_ignore_images
    ]

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

    def to_s
        name
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
        new flatten( data )
    end

    private

    def validate_description
        return if ActionController::Base.helpers.strip_tags( description ) == description
        errors.add :description, 'cannot contain HTML, please use Markdown instead'
    end

end
