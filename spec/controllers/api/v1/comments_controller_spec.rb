require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::CommentsController, type: :controller do
  describe "Mobile - Comments API - " do
    
    before do
      request.headers["Authorization"] = ENV["APP_LOGIN_TOKEN"]
    end

    it "should create comments" do
      boolean = ['true','false']
      post :create, params: {event_id: ChildEvent.first.id, comment: "foo", is_reply: false}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return event comments" do
      post :comments, params: {event_id: ChildEvent.first.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return commented events" do
      get :get_commented_events
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should delete event comments" do
      post :delete_event_comments, params: {event_id: ChildEvent.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should mark the comment as read" do
      post :mark_as_read, params: {event_id: ChildEvent.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
