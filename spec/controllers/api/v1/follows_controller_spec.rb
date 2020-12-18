require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::FollowsController, type: :controller do
  describe "Mobile - Follow API - " do
    
    before do
      request.headers["Authorization"] = ENV["APP_LOGIN_TOKEN"]
    end

    it "should follow" do
      post :follow, params: {following_id: Follow.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should unfollow" do
      post :unfollow, params: {following_id: Follow.last.following_id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return followers" do
      get :followers
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return followings" do
      get :followings
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return requests list" do
      get :requests_list
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should remove request" do
      get :remove_request, params: {request_id: FollowRequest.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return suggested businesses" do
      get :suggest_businesses
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
