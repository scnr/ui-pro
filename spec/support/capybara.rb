# require 'capybara/poltergeist'
#
# Capybara.register_driver :poltergeist do |app|
#     Capybara::Poltergeist::Driver.new( app, debug: true )
# end
#
# Capybara.asset_host        = 'http://localhost:3000'
# Capybara.javascript_driver = :chrome

Capybara.javascript_driver = :webkit
