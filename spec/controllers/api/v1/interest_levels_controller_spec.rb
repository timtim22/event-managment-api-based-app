require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::InterestLevelsController, type: :controller do
  describe "Mobile - InterestLevels API - " do

    before do
      request.headers["Authorization"] = ENV["APP_LOGIN_TOKEN"]
    end

    it "should create interest for an event" do
      post :create_interest, params: {event_id: ChildEvent.last.id }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should create going for an event" do
      post :create_going, params: {event_id: ChildEvent.last.id }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
