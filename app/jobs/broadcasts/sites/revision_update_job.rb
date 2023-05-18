# frozen_string_literal: true

module Broadcasts
  module Sites
    class RevisionUpdateJob < ApplicationJob
      queue_as :default

      def perform(revision_id)
        revision = Revision.find_by(id: revision_id)
        return if revision.blank?

        site = revision.site
        return if site.blank?

        user = site.user
        return if user.blank?

        SitesChannel.broadcast_to(
          user,
          site_id: site.id,
          html: SitesController.render(partial: 'sites/site', locals: { site: site }),
          action: :update
        )
      end
    end
  end
end
