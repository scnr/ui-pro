class SiteRole < ActiveRecord::Base
    include ProfileAttributes

    serialize :login_form_parameters, Hash

    belongs_to :site
    has_many   :scans
    has_many   :revisions, through: :scans

    validates_presence_of   :site
    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :site

    validates_presence_of   :session_check_url
    validates_presence_of   :session_check_pattern

    validates_presence_of   :scope_exclude_path_patterns
    # validates :validate_scope_exclude_path_patterns

    validates_presence_of   :login_form_url,
                                if: lambda { login_type == 'form' }
    validates_presence_of   :login_form_parameters,
                                if: lambda { login_type == 'form' }

    validates_presence_of   :login_script_code,
                                if: lambda { login_type == 'script' }

    %w(login_form_parameters).each do |m|
        define_method "#{m}=" do |string_or_hash|
            super self.class.string_list_to_hash( string_or_hash, '=' )
        end

        define_method "validate_#{m}" do
            check_patterns send(m), m.to_sym
        end
    end

    private

    def validate_scope_exclude_path_patterns
         return if scope_exclude_path_patterns.any?
         errors.add :scope_exclude_path_patterns, "can't be empty"
    end

    def string_list_to_array( string_or_array )
        case string_or_array
            when Array
                string_or_array
            else
                string_or_array.to_s.split( /[\n\r]/ ).reject(&:empty?)
        end
    end
end
