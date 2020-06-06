# require 'capybara/poltergeist'

# See: https://github.com/teampoltergeist/poltergeist/issues/520#issuecomment-84828753
class Capybara::Node::Element

    alias :old_click :click if method_defined? :click

    def click
        trigger('click')
    rescue Capybara::NotSupportedByDriverError
        old_click
    end
end

# Capybara.register_driver :poltergeist do |app|
#     Capybara::Poltergeist::Driver.new( app, js_errors: false )
# end

# Capybara.asset_host        = 'http://localhost:3000'

# :rack_test, :selenium, :selenium_headless, :selenium_chrome,
# :selenium_chrome_headless, :webkit, :webkit_debug
# Capybara.javascript_driver = :selenium_chrome
# Capybara.javascript_driver = :selenium_headless
# Capybara.javascript_driver = :selenium
Capybara.javascript_driver = :webkit

# We MUST specify a server other than WEBrick because it's a piece of shit and
# will result in random failures.
Capybara.server = :puma
