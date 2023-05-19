# frozen_string_literal: true

module Broadcasts
  module Profiles
    class BaseService < ApplicationService
      def call
        begin
          return false if user.blank? || profile.blank?

          broadcast_to_profile_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      def broadcast_to_profile_channel
        ProfileChannel.broadcast_to(user, **params)
      end

      def params
        { profile_id: profile.id, scans_count: scans.count, sidebar_html: render_sidebar_partial }
      end

      def render_sidebar_partial
        ProfilesController.render(
          partial: 'shared/sidebar_scans',
          locals: {
            scans: scans,
            with_site: true,
            with_count: true
          }
        )
      end

      def user
        nil
      end

      def profile
        nil
      end

      def scans
        @scans ||= profile.try(:scans) || []
      end
    end
  end
end
