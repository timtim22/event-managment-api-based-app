require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::ChatsController, type: :controller do
  describe "Mobile - Chats API - " do

    before do
      request.headers["Authorization"] = ENV["APP_LOGIN_TOKEN"]
    end

    it "should send message" do
      post :send_message, params: {:recipient_id => User.app_users.first.id, :message => "foo"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return chat history" do
      post :chat_history, params: {sender_id: User.app_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should get people who chatted" do
      get :chat_people
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should clear conversation" do
      get :clear_conversation, params: {user_id: User.app_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should clear message" do
      get :clear_chat, params: {message_id: Message.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    # it "should mark chat as read" do
    #   get :mark_as_read, params: {sender_id: User.app_users.last.id}
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end
  end
end
