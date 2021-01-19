RSpec.configure do |config|
 config.before(:each) do
  ENV["APP_LOGIN_TOKEN"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMiwiZXhwIjoyMzY4NDI2ODEyfQ.c_kclaxycIi86JFaUpIT989JoB3ODsZUY2Ifj-MUz70"
  ENV["WEB_LOGIN_TOKEN"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjIzNjgzMzkyMTh9.EoyXJsgUei1QKF5BLrnT2WwDkVO_Yw6LUPaK97uTRdE"
 end
end
