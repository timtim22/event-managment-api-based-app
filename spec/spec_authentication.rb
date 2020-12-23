RSpec.configure do |config|
 config.before(:each) do
  ENV["APP_LOGIN_TOKEN"] = ENV["APP_LOGIN"]
  ENV["WEB_LOGIN_TOKEN"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNiwiZXhwIjoyMzY2MDg3MzE0fQ.s8WHI_83rYUIU7PeQEa8YGzG8ihf7MQIcETF7XXdKhs"
 end
end
