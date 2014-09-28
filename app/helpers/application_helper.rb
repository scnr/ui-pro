module ApplicationHelper

    def refreshable_partial( resource, options = {} )
        options[:path]    = refreshable_partial_channel_path( resource )
        options[:partial] = refreshable_partial_path( resource, options )

        options[:tagname] ||= 'div'
        options[:id]      ||= options[:path][1..-1].gsub( '/', '_' )
        options[:classes] ||= nil

        render partial: 'shared/refreshable_partial', locals: options
    end

    def refresh_partial( resource, options = {} )
        current_user.notify_browser(
            refreshable_partial_channel( resource ),
            render_to_string( partial: refreshable_partial_path( resource, options ) )
        )
    end

    def refreshable_partial_channel( resource )
        "refreshable-partial://#{refreshable_partial_channel_path( resource )}"
    end

    def refreshable_partial_channel_path( resource )
        resource = refreshable_partial_prepare_resource( resource )

        partial  = resource.shift
        path     = '/'

        resource.each do |segment|
            case segment
                when ActiveRecord::Base
                    path << "#{segment.class.to_s.tableize}/#{segment.id}/"

                else
                    path << "#{segment}/"
            end
        end

        "#{path}#{partial}"
    end

    def refreshable_partial_path( resource, options = {} )
        resource = refreshable_partial_prepare_resource( resource )

        views = resource.last.is_a?( ActiveRecord::Base ) ?
            resource.last.class.to_s.tableize : resource.last.to_s

        partial = "#{views}/#{resource.first}"
        partial << ".#{options[:format]}" if options[:format]
        partial
    end

    def refreshable_partial_prepare_resource( resource )
        resource = [resource].flatten
        return resource.dup if resource.size > 1
        [resource, params[:controller]].flatten
    end

    def link_to_url_with_external( external_url, internal_url = nil, options = {} )
        render partial: 'shared/link_to_url_with_external', locals: {
            internal_url: internal_url,
            external_url: external_url,
            options:      options
        }
    end

    def scoped_find_each( scope, batch = 1000, &block )
        (0..scope.size).step( batch ) do |i|
            scope.offset(i).limit(batch).each(&block)
        end
    end

    def md( markdown )
        html = Kramdown::Document.new( markdown ).to_html.recode
        Loofah.fragment( html ).scrub!(:prune).to_s
    end

end
