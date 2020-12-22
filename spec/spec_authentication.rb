RSpec.configure do |config|
 config.before(:each) do
  ENV["APP_LOGIN_TOKEN"] = ENV["APP_LOGIN"]
  ENV["WEB_LOGIN_TOKEN"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNiwiZXhwIjoyMzY2MDEzOTk5fQ.ZUHXxFzpZIAQYrkG49g5RjYRLKuyGNTapL14fTcsV9I"
 end
end
