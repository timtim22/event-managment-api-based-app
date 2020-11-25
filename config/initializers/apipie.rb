Apipie.configure do |config|
  config.app_name                = "MygoAdmin"
  config.api_base_url            = ""
  config.doc_base_url            = "/api-doc"
  config.translate = false
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"

  config.app_info["1.0"] = "
    Available APIs for mobile and Dashboard
  "
end
