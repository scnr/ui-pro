require 'active_support/concern'

module ProfileRpcHelpers
    extend ActiveSupport::Concern

    module ClassMethods
        def flatten( data )
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

            options
        end
    end

    def to_rpc_options
        opts = {}
        attributes.each do |k, v|
            next if !self.class::RPC_OPTS.include?( k.to_sym ) || v.nil? ||
                (v.respond_to?( :empty? ) ? v.empty? : false)

            if (group_name = find_group_option( k ))
                group_name = group_name.to_s
                opts[group_name] ||= {}
                opts[group_name][k[group_name.size+1..-1]] = v
            else
                opts[k] = v
            end
        end

        opts
    end

    def find_group_option( name )
        Arachni::Options.group_classes.keys.find { |n| name.start_with? "#{n}_" }
    end
end
