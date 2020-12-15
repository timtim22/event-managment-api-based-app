require 'rails_helper'
require "spec_helper"
require "spec_app_login"


RSpec.describe Api::V1::CommentsController, type: :controller do
  describe "Mobile - Comments API - " do

    it "should create comments" do
      post :create, params: {event_id: Event.first.id, comment: "foo", is_reply: "false"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return event comments" do
      post :comments, params: {event_id: Event.first.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return commented events" do
      get :get_commented_events
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should delete event comments" do
      post :delete_event_comments, params: {event_id: Event.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should mark the comment as read" do
      post :mark_as_read, params: {event_id: Event.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
