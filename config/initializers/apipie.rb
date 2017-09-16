Apipie.configure do |config|
  config.app_name                = "DriveIt"
  config.api_base_url            = ""
  config.doc_base_url            = "/apipie"
   config.default_locale = nil
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
