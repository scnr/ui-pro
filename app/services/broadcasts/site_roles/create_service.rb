# frozen_string_literal: true

module Broadcasts
  module SiteRoles
    class CreateService < BaseService
      def initialize(site_role_id:)
        @site_role_id = site_role_id
      end

      private

      attr_reader :site_role_id

      def site_role
        @site_role ||= SiteRole.find(site_role_id)
      end

      def user
        @user ||= site_role.site.try(:user)
      end

      def action
        :create
      end
    end
  end
end
