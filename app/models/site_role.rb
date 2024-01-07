class SiteRole < ActiveRecord::Base
    include WithCustomSerializer
    include WithEvents
    include WithScannerOptions

    events skip: [:created_at, :updated_at],
                    # If this is a copy made by a revision don't bother.
                    unless: Proc.new { |t| t.revision_id }

    set_scanner_options(
        session_check_url:              String,
        session_check_pattern:          String,
        scope_exclude_path_patterns:    { type: Array,  validate: :patterns, format: :lsv }
    )

    custom_serialize :login_form_parameters, Hash

    belongs_to :site, optional: true
    belongs_to :revision, optional: true

    has_many   :scans, -> { order id: :desc }
    has_many   :revisions, through: :scans

    validates :login_type, presence: true, inclusion: { in: %w(none form script) }

    validates_presence_of   :site,
                            # If it has a revision it means it's a frozen copy
                            # for the revision, to keep as reference.
                            # Thus, it won't have a #site.
                            if: lambda { !revision }
    validates_presence_of   :name
    validates_uniqueness_of :name, scope: [:site, :revision]

    validates_presence_of   :session_check_url,
                            if: lambda { !guest? }
    validates_presence_of   :session_check_pattern,
                            if: lambda { !guest? }

    validates_presence_of   :scope_exclude_path_patterns,
                            if: lambda { !guest? }

    validates_presence_of   :login_form_url,
                                if: lambda { login_type == 'form' }
    validates_presence_of   :login_form_parameters,
                                if: lambda { login_type == 'form' }

    validates_presence_of   :login_script_code,
                                if: lambda { login_type == 'script' }

    validate :validate_login_script_code_syntax
    validate :validate_session_check_pattern

    # Broadcasts callbacks.
    after_create_commit :broadcast_create_job
    after_update_commit :broadcast_update_job
    after_destroy_commit :broadcast_destroy_job

    def self.guest
        where( login_type: 'none' ).first
    end

    def to_scanner_options
        return {} if login_type == 'none'

        rpc_options = super

        if login_type == 'form'
            rpc_options.merge!(
                'plugins' => {
                    'login_form' => {
                        'url'        => login_form_url,
                        'parameters' => login_form_parameters.
                            map { |k, v| "#{k}=#{v}" }.join('&'),
                        'check'      => session_check_pattern
                    }
                }
            )
        else
            rpc_options.merge!(
                'plugins' => {
                    'login_script' => {
                        'script' => login_script_code_tempfile
                    }
                }
            )
        end

        rpc_options
    end

    def login_script_code_tempfile
        path = create_login_script_code_tempfile_path
        return path if File.exists path

        IO.write( path, login_script_code )
        path
    end

    def login_script_code_error_line
        return if !errors.messages[:login_script_code] ||
            errors.messages[:login_script_code].empty?

        line = errors.messages[:login_script_code].first.match( /Line (\d+)/ )
        return if !line || !line[1]

        line[1].to_i
    end

    def guest?
        login_type == 'none'
    end

    def to_s
        name
    end

    private

    def validate_login_script_code_syntax
        file = nil

        return if login_type != 'script'
        return if login_script_code.to_s.empty?

        file = Tempfile.new('foo')
        file.write login_script_code

        _, stderr, status =
            Open3.capture3( "#{RbConfig.ruby} -c #{login_script_code_tempfile}" )

        return if status.exitstatus == 0

        errors.add :login_script_code, stderr.gsub( "#{login_script_code_tempfile}:", 'Line ' )
    ensure
        file.close if file
    end

    def validate_session_check_pattern
        check_pattern( self, :session_check_pattern, session_check_pattern )
    end

    def create_login_script_code_tempfile_path
        "#{Dir.tmpdir}/#{self.class}-#{login_script_code.to_s.persistent_hash}" <<
            '-login_script_code.rb'
    end

    def broadcast_create_job
        Broadcasts::SiteRoles::CreateJob.perform_later(id)
    end

    def broadcast_update_job
        Broadcasts::SiteRoles::UpdateJob.perform_later(id)
    end

    def broadcast_destroy_job
        Broadcasts::SiteRoles::DestroyJob.perform_later(id, site&.user&.id)
    end

end
