require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::SearchController, type: :controller do
  describe "Mobile - Search API - " do

    before do
      request.headers["Authorization"] = @app_login_token
    end

    it "should search events" do
      post :global_search, params: {resource_type: 'Event', search_term: "Test"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
