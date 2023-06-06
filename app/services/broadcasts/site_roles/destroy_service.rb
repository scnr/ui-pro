# frozen_string_literal: true

module Broadcasts
  module SiteRoles
    class DestroyService < BaseService
      def initialize(site_role_id:, user_id:)
        @site_role_id = site_role_id
        @user_id = user_id
      end

      private

      attr_reader :site_role_id, :user_id

      def user
        @user ||= User.find(user_id)
      end

      def params
        { site_role_id: site_role_id, action: action }
      end

      def action
        :destroy
      end

      alias site_role site_role_id
    end
  end
end
