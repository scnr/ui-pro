module BreadcrumbsHelper
    def title( title )
        content_for :title, title.to_s
    end

    def breadcrumbs
        @navigation ||= []
    end

    def title_breadcrumbs
        breadcrumbs.map { |b| b[:title] }.reverse.join( ' - ' )
    end

    def breadcrumb_add( title, url )
        breadcrumbs << { title: title, url: url }
    end

    def render_breadcrumbs
        render partial: 'layouts/breadcrumbs', locals: { breadcrumbs: breadcrumbs }
    end

    def active_controller?( controller )
        params[:controller] == controller
    end

    def mark_if_active( controller )
        'class="active"'.html_safe if active_controller?( controller )
    end
end
