class SiteRole < ActiveRecord::Base
    include ProfileAttributes
    include ProfileRpcHelpers

    serialize :login_form_parameters, Hash

    belongs_to :site
    has_many   :scans
    has_many   :revisions, through: :scans

    validates :login_type, presence: true, inclusion: { in: %w(none form script) }

    validates_presence_of   :site
    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :site

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

    def self.guest
        where( login_type: 'none' ).first
    end

    %w(login_form_parameters).each do |m|
        define_method "#{m}=" do |string_or_hash|
            super self.class.string_list_to_hash( string_or_hash, '=' )
        end
    end

    def to_rpc_options
        return {} if login_type == 'none'

        rpc_options = super

        if login_type == 'form'
            rpc_options.merge!(
                'plugins' => {
                    'autologin' => {
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
        return path if File.exists? path

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
        check_pattern( session_check_pattern, :session_check_pattern )
    end

    def create_login_script_code_tempfile_path
        "#{Dir.tmpdir}/#{self.class}-#{login_script_code.to_s.persistent_hash}" <<
            '-login_script_code.rb'
    end
end
