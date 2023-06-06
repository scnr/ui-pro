# frozen_string_literal: true

require 'action_cable/testing/rspec'
require 'action_cable/testing/rspec/features'

RSpec.configure do |config|
  config.include ActionCable::TestHelper
end
