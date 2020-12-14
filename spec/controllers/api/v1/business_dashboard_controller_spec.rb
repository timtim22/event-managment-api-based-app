require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::BusinessDashboardController, type: :controller do
  describe "Mobile - BusinessDashboard API - " do

    before do #not for login API
      request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMiwiZXhwIjoyMzY1MzE0MDI1fQ.ST9BF1XMUOMvvJ42ruT1Qq1p_kb21d_o-rZVdXS0LVU"
    end

    it "should get business details" do
      get :home
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should get events details" do
      get :events
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should get special offers details" do
      get :special_offers
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should get competitions details" do
      get :competitions
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
