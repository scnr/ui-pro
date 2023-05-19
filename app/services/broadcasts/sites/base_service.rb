# frozen_string_literal: true

module Broadcasts
  module Sites
    class BaseService < ApplicationService
      def call
        begin
          return false if user.blank? || site.blank?

          broadcast_to_sites_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      def broadcast_to_sites_channel
        SitesChannel.broadcast_to(user, **params)
      end

      def params
        { site_id: site.id, site_html: render_site_partial, action: action }
      end

      def render_site_partial
        SitesController.render(partial: 'sites/site', locals: { site: site })
      end

      def user
        nil
      end

      def site
        nil
      end

      def action
        nil
      end
    end
  end
end
