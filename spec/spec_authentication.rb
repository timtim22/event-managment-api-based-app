RSpec.configure do |config|
 config.before(:each) do
  ENV["APP_LOGIN_TOKEN"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo1LCJleHAiOjIzNjgzNDg4NDd9.SqgUyBqC0tkGopadOOw2hNSMww8ePDbsbJXcDlsQYqw"
  ENV["WEB_LOGIN_TOKEN"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjIzNjgzMzkyMTh9.EoyXJsgUei1QKF5BLrnT2WwDkVO_Yw6LUPaK97uTRdE"
 end
end
