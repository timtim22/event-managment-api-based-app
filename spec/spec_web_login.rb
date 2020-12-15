RSpec.configure do |config|

 config.before(:each) do
  request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMiwiZXhwIjoyMzY0OTgxNzYxfQ.Dq_FXVHsg5OeEuLS8zSTPb-VI7vGgsc-NuYvQNKWR7c"
 end

end
