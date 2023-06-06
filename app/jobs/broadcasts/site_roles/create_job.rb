# frozen_string_literal: true

module Broadcasts
  module SiteRoles
    class CreateJob < ApplicationJob
      queue_as :default

      def perform(id)
        Broadcasts::SiteRoles::CreateService.call(site_role_id: id)
      end
    end
  end
end
