# frozen_string_literal: true

module Broadcasts
  module Profiles
    class BaseService < ApplicationService
      def call
        begin
          return false if user.blank?

          broadcast_to_profile_channel

          true
        rescue ActiveRecord::RecordNotFound
          false
        end
      end

      private

      def profile
        nil
      end

      def action
        nil
      end

      def user
        @user ||= profile.user
      end

      def scans
        @scans ||= profile.try(:scans) || []
      end

      def broadcast_to_profile_channel
        ProfileChannel.broadcast_to(user, **params)
      end

      def params
        {
          profile_id: profile.id,
          action: action,
          sidebar_html: render_sidebar_partial,
          profile_html: render_profile_partial
        }
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

      def render_profile_partial
        ProfilesController.render(
          partial: 'profiles/row_field',
          locals: { profile: profile }
        )
      end
    end
  end
end
