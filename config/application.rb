require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DriveIt
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
config.active_job.queue_adapter = :delayed_job
    config.autoload_paths += %W(#{config.root}/app/classes/)
  config.assets.compile = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
