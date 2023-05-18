# frozen_string_literal: true

module Broadcasts
  module Sites
    class SiteCreateJob < ApplicationJob
      queue_as :default

      def perform(site_id)
        site = Site.find_by(id: site_id)
        return if site.blank?

        user = site.user
        return if user.blank?

        SitesChannel.broadcast_to(
          user,
          site_id: site.id,
          html: SitesController.render(partial: 'sites/site', locals: { site: site }),
          action: :create
        )
      end
    end
  end
end
