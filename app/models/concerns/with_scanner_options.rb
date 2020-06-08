require 'active_support/concern'

module WithScannerOptions
    extend ActiveSupport::Concern

    SERIALIZE_TYPES = Set.new([Array, Hash])
    PARSE_TYPES     = Set.new([:csv, :ssv, :lsv])

    def to_scanner_options
        options = {}
        self.class.scanner_option_name_translations.each do |ui, scanner|
            value      = self[ui]
            group_name = find_scanner_option_group_name( scanner )

            if group_name
                group_name = group_name.to_s
                options[group_name] ||= {}
                options[group_name][scanner[group_name.size+1..-1]] = value
            else
                options[scanner] = value
            end
        end
        options
    end

    def find_scanner_option_group_name( name )
        @find_scanner_option_group_name_cache ||= {}

        if @find_scanner_option_group_name_cache.include? name
            return @find_scanner_option_group_name_cache[name]
        end

        @find_scanner_option_group_name_cache[name] =
            SCNR::Engine::Options.group_classes.keys.
                find { |n| name.start_with? "#{n}_" }
    end

    module ClassMethods
        def set_scanner_options( scanner_options )
            @scanner_options                  = scanner_options
            @scanner_option_name_translations = {}
            @permitted_attributes             = []

            @scanner_options.each do |attribute_name_or_translation, options|
                ui_name, scanner_name =
                    scanner_option_translate_name( attribute_name_or_translation )

                if !self.supported_scanner_options.include?( scanner_name )
                    fail "#{self}: Scanner option '#{scanner_name}' does not exist."
                end

                if !self.column_names.include?( ui_name )
                    fail "#{self}: Column '#{ui_name}' does not exist."
                end

                @scanner_option_name_translations[ui_name] = scanner_name
                process_options( ui_name, scanner_name, options )
            end
        end

        def parse_options
            @parse_options
        end

        def permitted_attributes
            scanner_option_name_translations.keys
        end

        def scanner_option_name_translations
            @scanner_option_name_translations
        end

        def scanner_option_translate_name( name )
            return [name.to_s, name.to_s] if name.is_a? Symbol

            name.to_a.first.map(&:to_s)
        end

        def process_options( ui_name, scanner_name, options )
            ui_name = ui_name.to_sym

            @parse_options ||= {}

            case options
                when Hash
                    validate = options[:validate]
                    case validate
                        when true
                            validate ui_name, "validate_#{ui_name}".to_sym

                        when :patterns
                            validate ui_name do |instance|
                                check_patterns( instance, ui_name )
                            end

                        when :pattern
                            validate ui_name do |instance|
                                check_pattern(
                                    instance, ui_name, instance[ui_name]
                                )
                            end
                    end

                    format = options[:format]
                    if format
                        if !PARSE_TYPES.include?( format )
                            fail "#{self}: Format type '#{format}' does not exist."
                        end

                        @parse_options[ui_name] = {
                            class:  options[:type],
                            format: format
                        }
                    end

                    if SERIALIZE_TYPES.include? options[:type]
                        custom_serialize ui_name, options[:type]
                    end

                when Symbol

                when Class

                    if SERIALIZE_TYPES.include? options
                        custom_serialize ui_name, options
                    end

            end

            # TODO: Fail on invalid scanner_name or type mismatch.
        end

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

        def supported_scanner_options
            return @supported_scanner_options if @supported_scanner_options

            options = Set.new( SCNR::Engine::Options.attr_accessors.map(&:to_s) )
            SCNR::Engine::Options.group_classes.each do |name, klass|
                next if SCNR::Engine::Options::TO_RPC_IGNORE.include? name

                klass.attributes.each do |attribute|
                    options << "#{name}_#{attribute}"
                end
            end
            @supported_scanner_options = options
        end

    end

    private

    def check_patterns( instance, attribute )
        instance[attribute].each do |pattern|
            check_pattern( instance, attribute, pattern )
        end
    end

    def check_pattern( instance, attribute, pattern )
        Regexp.new( pattern.to_s )
        true
    rescue RegexpError => e
        instance.errors.add attribute,
                            "invalid pattern #{pattern.inspect} (#{e})"
        false
    end

end
