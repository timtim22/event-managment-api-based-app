# require 'rails_helper'
# require "spec_helper"


# RSpec.describe Api::V1::SearchController, type: :controller do
#   describe "Mobile - Search API - " do

#     before do #not for login API
#       request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzI1ODg2fQ.C7f6OoljKzwuW6IIlAYIZ3HPxjRwBg1IhuBnnaV1eP0"
#     end

#     it "should search events" do
#       post :search_events, params: {search_bases: ['name']}
#       expect(response).to have_http_status(200)
#       expect(JSON.parse(response.body)["success"]).to eq(true)
#     end
#   end
# end
