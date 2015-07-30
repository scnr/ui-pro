module SidebarHelper

    def add_to_sidebar( &block )
        fail 'Missing block.' if !block_given?

        (@sidebar ||= ''.html_safe) << capture( &block )
    end

    def sidebar
        @sidebar
    end

end
