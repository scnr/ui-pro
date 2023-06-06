# frozen_string_literal: true

module Broadcasts
  module Devices
    class UpdateService < CreateService
      private

      def action
        :update
      end
    end
  end
end
