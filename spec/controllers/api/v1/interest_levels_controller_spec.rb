require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::InterestLevelsController, type: :controller do
  describe "Mobile - InterestLevels API - " do

    before do
      request.headers["Authorization"] = @app_login_token
    end

    it "should create interest for an event" do
      post :create_interest, params: {event_id: Event.last.id }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should create going for an event" do
      post :create_going, params: {event_id: Event.last.id }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
