require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"
require "secure_headers/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

AVAILABLE_LOCALES = {
  en: 'English',
  pt: 'Português'
}

DEFAULT_LOCALE = :pt

module Falae
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_view.form_with_generates_remote_forms = true

    # Use Rack::Attack protection middleware
    config.middleware.use Rack::Attack

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Whitelist locales available for the application
    I18n.available_locales = AVAILABLE_LOCALES.keys

    # Set default locale to something other than :en
    I18n.default_locale = DEFAULT_LOCALE

    config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
  end
end
