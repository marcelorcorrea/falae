source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.7', '>= 6.1.7.4'

# Use Puma as the app server
gem 'puma', '~> 5.6'
gem 'puma-daemon', require: false

# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem 'webpacker', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.15'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# JQuery
gem 'jquery-rails', '~> 4.4.0'

# Awesome Fonts (Icons)
gem "font-awesome-rails", '~> 4.7.0'

# Security headers
gem 'secure_headers', '~>3.9.0'

# Throttling/blocking protection middleware
gem "rack-attack", "~> 5.0"

# File attachment management for ActiveRecord
gem 'kt-paperclip', '~> 7.2.0'

gem 'will_paginate', '~> 3.1.6'

gem 'rufus-scheduler', '~> 3.4.2'

gem 'prawn', '~> 2.4.0'

# HTTP Accept-Language header filtering library
gem "http_accept_language", "~> 2.1"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'brakeman', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 3.26'
  # gem 'selenium-webdriver', '>= 4.0.0.rc1'
  # Easy installation and use of web drivers to run system tests with browsers
  # gem 'webdrivers'

  gem 'rspec-rails'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails'
  gem 'simplecov', require: false
end

group :production do
  gem 'mysql2', '~>0.5'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
