require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::EventsController, type: :controller do
  describe "Mobile - Events API - " do
    
    before do
      request.headers["Authorization"] = @app_login_token
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
      get :get_map_events, params: {date: "11-12-2020"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
