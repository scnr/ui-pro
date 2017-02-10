module FrameworkHelper

    # We may be able to identify lots of different DBs but that's just based
    # on the errors string matches by the generic sql_injection check.
    #
    # These are the actual platforms which can help us narrow down the audit.
    AUDITABLE_DB_PLATFORMS = [
        :sql,
        :mysql,
        :pgsql,
        :mssql,
        :nosql,
        :mongodb
    ]

    def framework( &block )
        fail 'This method requires a block.' if !block_given?
        block.call SCNREngineFramework
    end

    def valid_platforms( type = nil )
        if type.nil?
            platforms = platform_manager.valid
        elsif type == :db
            platforms = AUDITABLE_DB_PLATFORMS
        else
            platforms = platform_manager.send( type ).valid
        end

        platforms.map( &:to_s )
    end

    def platform_type_fullname( type )
        SCNR::Engine::Platform::Manager::TYPES[type]
    end

    def platform_shortnames
        SCNR::Engine::Platform::Manager.valid
    end

    def platform_fullname( platform )
        platform_manager.fullname platform
    end

    def platform_manager
        @platform_manager ||= SCNR::Engine::Platform::Manager.new
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

    def default_plugins
        DEFAULT_PLUGINS
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

                    if manager[name] <= SCNR::Engine::Reporter::Base && manager[name].has_outfile?
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
