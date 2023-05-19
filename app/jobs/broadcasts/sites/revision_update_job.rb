# frozen_string_literal: true

module Broadcasts
  module Sites
    class RevisionUpdateJob < ApplicationJob
      queue_as :default

      def perform(id)
        revision = find_revision(id)
        return if revision.blank?

        site = find_site(revision)
        return if site.blank?

        user = find_user(site)
        return if user.blank?

        broadcast_revision_update(user, site)
      end

      private

      def find_revision(id)
        Revision.find_by(id: id)
      end

      def find_site(revision)
        revision.site
      end

      def find_user(site)
        site.user
      end

      def broadcast_revision_update(user, site)
        SitesChannel.broadcast_to(
          user,
          site_id: site.id,
          html: render_site_partial(site),
          action: :update
        )
      end

      def render_site_partial(site)
        SitesController.render(partial: 'sites/site', locals: { site: site })
      end
    end
  end
end
