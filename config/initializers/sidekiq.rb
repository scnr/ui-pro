# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/1' } }
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/1' } }
end
