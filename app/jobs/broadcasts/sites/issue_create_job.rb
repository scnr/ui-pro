# frozen_string_literal: true

module Broadcasts
  module Sites
    class IssueCreateJob < ApplicationJob
      queue_as :default

      def perform(issue_id)
        issue = Issue.find_by(id: issue_id)
        return if issue.blank?

        site = issue.revision&.site
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
