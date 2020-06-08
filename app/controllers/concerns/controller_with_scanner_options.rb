module ControllerWithScannerOptions
    extend ActiveSupport::Concern

    SCANNER_OPTIONS_HASH_DELIMITER = '='
    SCANNER_OPTIONS_PARSERS        = {
        Array => {
            lsv: :parse_lsv_to_array,
            csv: :parse_csv_to_array,
            ssv: :parse_ssv_to_array
        },

        Hash => {
            lsv: :parse_lsv_to_hash,
        }
    }

    included do

        private

        define_method "#{model_param_name}_params" do
            permitted_params
        end

        def permitted_params
            params.require( model_param_name.to_sym ).permit( permitted_attributes )
        end
    end

    module ClassMethods
        def model_instance
            instance_variable_get "@#{model_param_name}"
        end

        def model
            controller_name.classify.constantize
        end

        def model_param_name
            controller_name.singularize
        end

        def model_name
            model.model_name.human
        end
    end
    include ClassMethods

    def parsed_params
        # ap model
        # ap model.parse_options
        parsed = permitted_params

        model.parse_options.each do |param, options|
            format = options[:format]
            cast   = options[:class]

            parsers = SCANNER_OPTIONS_PARSERS[cast]
            if !parsers
                fail "#{model}: No parsers for '#{cast}' for parameter '#{param}'."
            end

            parser = parsers[format]
            if !parser
                fail "#{model}: No '#{cast}' parser for '#{format}' for parameter '#{param}'."
            end

            parser = method( parsers[format] )
            parsed[param] = parser.call( parsed[param] )
        end

        parsed.permit( permitted_parsed_attributes )
    end

    def permitted_attributes
        return if !params[model_param_name]
        @permitted_attributes ||= model.scanner_option_name_translations.keys.map(&:to_sym)
    end

    def permitted_parsed_attributes
        return if !params[model_param_name]
        return @permitted_parsed_attributes if @permitted

        @permitted_parsed_attributes = permitted_attributes.dup

        model.parse_options.each do |param, options|
            cast = options[:class]
            next if !cast

            @permitted_parsed_attributes.delete param
            @permitted_parsed_attributes << { param => cast.new }
        end

        @permitted_parsed_attributes
    end

    def parse_csv_to_array( string )
        return [] if !string
        string.split( /,\s+/ ).reject(&:empty?)
    end

    def parse_ssv_to_array( string )
        return [] if !string
        string.split( /\s+/ )
    end

    def parse_lsv_to_array( string )
        return [] if !string
        string.split( /[\n\r]/ ).reject(&:empty?)
    end

    def parse_lsv_to_hash( string )
        return {} if !string
        Hash[string.split( /[\n\r]/ ).reject(&:empty?).
            map{ |rule| rule.split( SCANNER_OPTIONS_HASH_DELIMITER, 2 ) }]
    end

end
