source 'https://rubygems.org'

gem 'rails', '7.0.2.3'
gem 'sass-rails'
gem 'closure-compiler'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'jbuilder'
gem 'bootstrap-sass', '3.3.6'
gem 'font-awesome-sass'
gem 'font-kit-rails'
gem 'devise'
# gem 'devise_security_extension', github: 'phatworx/devise_security_extension'
gem 'simple_form'

gem 'oj'
gem 'oj_mimic_json'

gem 'webpacker'
gem 'kramdown'
gem 'loofah'

gem 'd3-rails', '3.5.16'
gem 'c3-rails', '0.4.11'

gem 'ace-rails-ap'

gem 'coderay'
gem 'diffy'

gem 'pg'

gem 'parse-cron'

gem 'dotiw'

gem 'vmstat'

gem 'sys-proctable'

# Audit trail
gem 'paper_trail'#, '~> 4.0.0'

group :doc do
    gem 'sdoc', '~> 0.4.0'
end

group :development do
    gem 'listen'
    gem 'spring'
    gem 'better_errors'
    gem 'binding_of_caller'
    # gem 'quiet_assets'
    gem 'rails_layout'
    gem 'bullet'
    # gem 'rails-footnotes'
end

group :test do
    gem 'shoulda'
    # gem 'capybara-webkit'
    # gem 'poltergeist'
    gem 'capybara'
    gem 'database_cleaner'
    gem 'faker'
    gem 'launchy'
    gem 'selenium-webdriver'
    gem 'factory_girl_rails'
    gem 'rspec-rails'
end

group :development, :test do
    gem 'puma'
    gem 'awesome_print'
end

gem 'nokogiri', github: 'sparklemotion/nokogiri', branch: 'main'
gem 'ethon',    github: 'typhoeus/ethon', branch: 'thread-safe-easy-handle-cleanup'

if File.exist? '../../qadron/dsel'
    gem 'dsel', path: '../../qadron/dsel'
end

if File.exist? '../../qadron/toq'
    gem 'toq', path: '../../qadron/toq'
end

if File.exist? '../../qadron/cuboid'
    gem 'cuboid', path: '../../qadron/cuboid'
end

if File.exist? '../application'
    gem 'scnr-application', path: '../application'
end

if File.exist? '../engine'
    gem 'scnr-engine', path: '../engine'
end
