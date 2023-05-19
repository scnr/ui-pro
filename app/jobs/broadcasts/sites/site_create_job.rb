# frozen_string_literal: true

module Broadcasts
  module Sites
    class SiteCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        site = find_site(id)
        return if site.blank?

        user = find_user(site)
        return if user.blank?

        broadcast_site_create(user, site)
      end

      private

      def find_site(id)
        Site.find_by(id: id)
      end

      def find_user(site)
        site.user
      end

      def broadcast_site_create(user, site)
        SitesChannel.broadcast_to(
          user,
          site_id: site.id,
          html: render_site_partial(user, site),
          action: :create
        )
      end

      def render_site_partial(user, site)
        SitesController.render(partial: 'sites/site', locals: { site: site })
      end
    end
  end
end
