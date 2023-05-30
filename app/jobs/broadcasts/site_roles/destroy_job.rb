# frozen_string_literal: true

module Broadcasts
  module SiteRoles
    class DestroyJob < ApplicationJob
      queue_as :anycable

      def perform(site_role_id, user_id)
        Broadcasts::SiteRoles::DestroyService.call(site_role_id: site_role_id, user_id: user_id)
      end
    end
  end
end
