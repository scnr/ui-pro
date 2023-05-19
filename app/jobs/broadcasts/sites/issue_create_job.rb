# frozen_string_literal: true

module Broadcasts
  module Sites
    class IssueCreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        issue = find_issue(id)
        return if issue.blank?

        site = find_site(issue)
        return if site.blank?

        user = find_user(site)
        return if user.blank?

        broadcast_issue_create(user, site)
      end

      private

      def find_issue(id)
        Issue.find_by(id: id)
      end

      def find_site(issue)
        issue.revision.try(:site)
      end

      def find_user(site)
        site.user
      end

      def broadcast_issue_create(user, site)
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
