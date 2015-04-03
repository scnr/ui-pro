module FrameworkHelper

    def framework( &block )
        fail 'This method requires a block.' if !block_given?
        block.call ArachniFramework
    end

    def valid_platforms( type = nil )
        (type.nil? ? platform_manager.valid : platform_manager.send( type ).valid).map( &:to_s )
    end

    def platform_type_fullname( type )
        Arachni::Platform::Manager::TYPES[type]
    end

    def platform_shortnames
        Arachni::Platform::Manager.valid
    end

    def platform_fullname( platform )
        platform_manager.fullname platform
    end

    def platform_manager
        @platform_manager ||= Arachni::Platform::Manager.new
    end

    def prepare_description( str )
        placeholder =  '--' + rand( 1000 ).to_s + '--'
        cstr = str.gsub( /^\s*$/xm, placeholder )
        cstr.gsub!( /^\s*/xm, '' )
        cstr.gsub!( placeholder, "\n" )
        cstr.chomp
    end

    def checks
        @_checks ||= components_for( :checks )
    end

    def plugins
        @_plugins ||= components_for( :plugins )
    end

    def content_type_for_report( format )
        reporters[format.to_s][:content_type] || 'application/octet-stream'
    end

    def reporters
        components_for( :reporters ).reject { |name, _| name == 'txt' }
    end

    def reports_with_outfile
        h = {}
        reporters.
            reject { |_, info| !info[:options] || !info[:options].
                                map { |o| o.name  }.include?( :outfile ) }.
            map { |shortname, info| h[shortname] = [info[:name], info[:description]] }
        h
    end

    def components_for( type, list = :available )
        path = File.join( Rails.root, 'config', 'component_cache', "#{type}_#{list}.yml" )

        if !File.exists?( path )
            components = framework do |f|
                (manager = f.send( type )).loaded.inject( {} ) do |h, name|
                    h[name] = manager[name].info.merge( path: manager.name_to_path( name ) )

                    h[name][:author]    = [ h[name][:author] ].flatten.map(&:strip)
                    h[name][:authors]   = h[name][:author]

                    if manager[name] <= Arachni::Reporter::Base && manager[name].has_outfile?
                        h[name][:extension] = manager[name].outfile_option.default.split( '.', 2 ).last
                    end
                    h
                end
            end

            components = Hash[components.sort]

            File.open( path, 'w' ) do |f|
                f.write components.to_yaml
            end
        end

        YAML.load( IO.read( path ) )
    end

    extend self
end
