require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::InterestLevelsController, type: :controller do
  describe "Mobile - InterestLevels API - " do

    before do #not for login API
      request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzI1ODg2fQ.C7f6OoljKzwuW6IIlAYIZ3HPxjRwBg1IhuBnnaV1eP0"
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
