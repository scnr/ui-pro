# frozen_string_literal: true

module Broadcasts
  module SiteRoles
    class UpdateJob < ApplicationJob
      queue_as :anycable

      def perform(id)
        Broadcasts::SiteRoles::UpdateService.call(site_role_id: id)
      end
    end
  end
end
