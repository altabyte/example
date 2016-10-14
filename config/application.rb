require File.expand_path('../boot', __FILE__)

require 'i18n/missing_translations'
require 'rails/all'


if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module OrderManager
  class Application < Rails::Application

    config.generators do |g|
      g.stylesheets false
      g.view_specs false
      g.helper_specs false
      g.test_fixture false
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.initialize_on_precompile = false

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/lib/jobs)
    config.autoload_paths += Dir["#{Rails.root.to_s}/app/datatables/**/"]

    config.app_middleware.use(I18n::MissingTranslations, "#{Dir.pwd}/config/locales/en.yml") if Rails.env.development?
    config.i18n.enforce_available_locales = true

    config.active_record.observers = :user_observer

    config.to_prepare do
      #Devise::SessionsController.skip_before_filter :check_location_set
    end

    Delayed::Worker.destroy_failed_jobs = false

    require 'silencer/logger'
    config.middleware.swap Rails::Rack::Logger, Silencer::Logger, :silence => ["/home/information_panel"]

    # Rack::MiniProfiler.config.position = 'right'
    # Rack::MiniProfiler.config.start_hidden = true

  end
end
