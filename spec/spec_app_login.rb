RSpec.configure do |config|

 config.before(:each) do
  request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzA5MzYyfQ.GLxTPsDhGAbWK7zoqSaX3UzRd9CJruc7tC0Rhe5TPY4"
 end

end
