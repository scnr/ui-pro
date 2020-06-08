class SiteProfile < ActiveRecord::Base
    include WithCustomSerializer
    include WithEvents
    include WithScannerOptions
    include ProfileImport
    include ProfileExport

    events skip: [:created_at, :updated_at],
                    # If this is a copy made by a revision don't bother.
                    unless: Proc.new { |t| t.revision_id }

    set_scanner_options(
        platforms:  { type: Array, validate: true },

        no_fingerprinting:  :bool,

        input_values:           { type: Hash,   validate: true, format: :lsv },
        audit_link_templates:   { type: Array,  validate: true, format: :lsv },

        scope_include_subdomains:       :bool,
        scope_https_only:               :bool,
        scope_auto_redundant_paths:     Integer,
        scope_extend_paths:             { type: Array, format: :lsv },
        scope_exclude_file_extensions:  { type: Array, format: :ssv },
        scope_exclude_path_patterns:    { type: Array, validate: :patterns, format: :lsv },
        scope_exclude_content_patterns: { type: Array, validate: :patterns, format: :lsv },

        { scope_template_path_patterns: :scope_redundant_path_patterns } =>
            { type: Array, validate: :patterns, format: :lsv },

        scope_url_rewrites:             { type: Hash, validate: true, format: :lsv },

        http_cookies:                   { type: Hash, validate: true, format: :lsv },
        http_request_headers:           { type: Hash, validate: true, format: :lsv },
        http_request_concurrency:       Integer,
        http_authentication_username:   String,
        http_authentication_password:   String,

        browser_cluster_wait_for_elements:  { type: Hash, validate: true, format: :lsv }
    )

    # Validate it's not greater than the global one.
    validates :max_parallel_scans, numericality: { greater_than: 0 }
    validate  :validate_max_parallel_scans

    belongs_to :site, optional: true
    belongs_to :revision, optional: true

    def to_s
        "Settings for #{site}"
    end

    private

    def validate_max_parallel_scans
        global = Settings.max_parallel_scans
        return if !global || max_parallel_scans <= global

        errors.add :max_parallel_scans,
                   "cannot be greater than the global setting of #{global}"
    end

    def validate_platforms
        platform_names = SCNR::Engine::Platform::Manager::PLATFORM_NAMES
        platforms.each do |platform|
            next if platform_names[platform.to_sym]
            errors.add :platforms, "unknown platform '#{platform}'"
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

    def validate_input_values
        input_values.each do |pattern, _|
            if pattern.empty?
                errors.add :input_values, 'pattern cannot be empty'
            end

            check_pattern( self, :input_values, pattern )
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

            next if !check_pattern( self, :scope_url_rewrites, pattern )

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

    def validate_browser_cluster_wait_for_elements
        browser_cluster_wait_for_elements.each do |pattern, css|
            if pattern.empty?
                errors.add :browser_cluster_wait_for_elements, 'pattern cannot be empty'
            end

            check_pattern( self, :browser_cluster_wait_for_elements, pattern )

            if css.to_s.strip.empty?
                errors.add :browser_cluster_wait_for_elements,
                           "rule '#{pattern}' is missing a CSS selector"
            end
        end
    end

end
