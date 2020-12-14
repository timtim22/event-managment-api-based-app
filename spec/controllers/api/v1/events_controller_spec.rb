require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::EventsController, type: :controller do
  describe "Mobile - Events API - " do

    before do #not for login API
      request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzI1ODg2fQ.C7f6OoljKzwuW6IIlAYIZ3HPxjRwBg1IhuBnnaV1eP0"
    end

    it "should return all competitions" do
      get :show_event, params: {event_id: Event.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return events" do
      get :index, params: {event_id: Event.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should report event" do
      get :report_event, params: {event_id: Event.last.id, reason: "foo"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return events by map" do
      get :get_map_events
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
