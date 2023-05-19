# frozen_string_literal: true

module Broadcasts
  module Sites
    class SiteDestroyService < BaseService
      def initialize(site:)
        @site = site
      end

      private

      attr_reader :site

      def params
        { site_id: site.id, action: action }
      end

      def user
        @user ||= site.user
      end

      def action
        :destroy
      end
    end
  end
end
