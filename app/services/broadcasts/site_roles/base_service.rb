# frozen_string_literal: true

module Broadcasts
  module SiteRoles
    class BaseService < ApplicationService
      def call
        begin
          return false if user.blank? || site_role.blank?

          broadcast_to_site_role_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      def broadcast_to_site_role_channel
        SiteRoleChannel.broadcast_to(user, **params)
      end

      def params
        {
          site_role_id: site_role.id,
          site_role_html: render_site_role_partial,
          sidebar_html: render_sidebar_partial,
          action: action
        }
      end

      def render_site_role_partial
        SiteRolesController.render(partial: 'table_row', locals: { site_role: site_role })
      end

      def render_sidebar_partial
        SiteRolesController.render(
          partial: 'shared/sidebar_scans',
          locals: {
            scans: scans,
            scan_details_options: {
              hide_scan_name: true
            }
          }
        )
      end

      def user
        nil
      end

      def site_role
        nil
      end

      def action
        nil
      end

      def scans
        @scans ||= site_role.scans
      end
    end
  end
end
