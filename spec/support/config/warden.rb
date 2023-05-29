# frozen_string_literal: true

require 'warden'

RSpec.configure do |config|
    config.include Warden::Test::Helpers
end
