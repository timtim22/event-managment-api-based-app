RSpec.configure do |config|
 config.before(:each) do
  ENV["APP_LOGIN_TOKEN"] = ENV["APP_LOGIN"]
  ENV["WEB_LOGIN_TOKEN"] = ENV["WEB_LOGIN"]
 end
end
