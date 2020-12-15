require 'rails_helper'
require "spec_helper"
require "spec_app_login"


RSpec.describe Api::V1::FriendshipsController, type: :controller do
  describe "Mobile - Friendships API - " do

    it "should send request" do
      post :send_request, params: {friend_id: User.app_users.first.id }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should check request status" do
      post :send_request, params: {friend_id: User.app_users.first.id }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should check friend requests" do
      get :friend_requests
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should accpet friend request" do
      get :accept_request, params: {request_id: FriendRequest.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    # it "should remove friend request" do
    #   get :remove_request, params: {user_id: FriendRequest.last.id}
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end
    # works with the notifications.

    it "should return my friends" do
      get :my_friends
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should remove friend" do
      post :remove_friend, params: {friend_id: User.app_users.last.friends.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return suggest friends" do
      get :suggest_friends
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return friend details" do
      get :get_friends_details, params: {user_id: User.app_users.last.friends.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
