require 'rails_helper'
require "spec_helper"

RSpec.describe Api::V1::Events::EventsController, type: :controller do
  describe "Mobile - Events API - " do
    
    before do
      request.headers["Authorization"] =ENV["APP_LOGIN_TOKEN"]
    end

    it "should return single event" do
      get :show_event, params: {event_id: ChildEvent.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return events" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should report event" do
      get :report_event, params: {event_id: ChildEvent.last.id, reason: "foo"}
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
