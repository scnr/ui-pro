module ApplicationHelper

    def refreshable_element( options = {}, &block )
        options.merge!( params.symbolize_keys.merge( options ) )

        tag = options[:tag] || 'div'
        id  = options[:id]  || url[1..-1].gsub( '/', '_' )

        html = <<-HTML
            <#{h tag} #{"id='#{h id}'" if id}
                class="refreshable #{h options[:class]}"
                data-refreshable="#{h refreshable_channel_path(options)}">#{h block.call if block_given?}</#{h tag}>
        HTML
        html.html_safe
    end

    def refreshable_channel_name( options = {} )
        "refreshable://#{refreshable_channel_path( options )}"
    end

    def refreshable_channel_path( options = {} )
        options.merge!( params.symbolize_keys.merge( options ) )

        url_for(
            controller: options[:controller],
            id:         options[:id],
            action:     options[:action],
            only_path:  true
        )
    end

end
