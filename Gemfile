source 'https://rubygems.org'
ruby '2.1.2'

gem 'rails', '4.1.4'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'bootstrap-sass'
gem 'devise'
gem 'pundit'
gem 'simple_form'
gem 'sidekiq'
gem 'typhoeus'
gem 'websocket-rails', '0.6.2'

group :doc do
    gem 'sdoc', '~> 0.4.0'
end

group :development do
    gem 'spring'
    gem 'better_errors'
    gem 'binding_of_caller', platforms: [:mri_21]
    gem 'quiet_assets'
    gem 'rails_layout'
end

group :test do
    gem 'shoulda'
    gem 'capybara-webkit'
    # gem 'poltergeist'
    gem 'capybara'
    gem 'database_cleaner'
    gem 'faker'
    gem 'launchy'
    gem 'selenium-webdriver'
    gem 'rspec-sidekiq'
    gem 'factory_girl_rails'
    gem 'rspec-rails'
end

group :development, :test do
    gem 'thin'
    gem 'sqlite3'
    gem 'awesome_print'
end

gem 'arachni-rpc', path: File.dirname( __FILE__ ) + '/../../../arachni-rpc-v0.2'
gem 'arachni',     path: File.dirname( __FILE__ ) + '/../../../arachni'
