Apipie.configure do |config|
  config.app_name                = "MygoAdmin"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  config.reload_controllers = false
  config.translate = false
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.app_info["1.0"] = "Available Mobile APIs Details"

end
