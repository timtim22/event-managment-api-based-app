Rails.application.configure do
  config.lograge.enabled = Rails.configuration.x.feature.lograge
  #config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.base_controller_class = ['ActionController::API', 'ActionController::Base']

  config.lograge.custom_options = lambda do |event|
    exceptions = %w[controller action format id]
    {
      request_time: Time.now,
      application: Rails.application.class.parent_name,
      process_id: Process.pid,
      host: event.payload[:host],
      remote_ip: event.payload[:remote_ip],
      ip: event.payload[:ip],
      x_forwarded_for: event.payload[:x_forwarded_for],
      params: event.payload[:params].except(*exceptions).to_json,
      rails_env: Rails.env,
      exception: event.payload[:exception]&.first,
      request_id:     event.payload[:headers]['action_dispatch.request_id'],
      # This is error for including exceptions and exception_backtrace
      #exception_message: "'#{event.payload[:exception]&.last}'
      #exception_backtrace: event.payload[:exception_object]&.backtrace&.join(","),
    }.compact
  end
end