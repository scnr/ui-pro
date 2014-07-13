class RenderWorker
    include Sidekiq::Worker

    def render( *args )
        view = ActionView::Base.new( ActionController::Base.view_paths, {} )

        class << view
            include ApplicationHelper
            include Rails.application.routes.url_helpers
        end

        view.render *args
    end
end
