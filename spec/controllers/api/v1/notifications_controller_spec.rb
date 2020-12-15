require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::NotificationsController, type: :controller do
  describe "Mobile - Notifications API - " do

    before do #not for login API
      request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzI1ODg2fQ.C7f6OoljKzwuW6IIlAYIZ3HPxjRwBg1IhuBnnaV1eP0"
    end

    it "should return notifications" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should ask location" do
      get :ask_location, params: {askee_ids: User.app_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    # it "should get location" do
    #   get :get_location, params: {
    #     lat: Profile.last.lat,
    #     lat: Profile.last.lng,
    #     asker_id: User.app_users.last.id
    #   }
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end
    #works with notifications

    # it "should send location" do
    #   get :send_location, params: {
    #     lat: Profile.last.lat,
    #     lat: Profile.last.lng,
    #     asker_id: User.app_users.last.id
    #   }
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end
    # works with notifications

    it "should mark notifications as read" do
      get :mark_as_read
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    # it "should send events reminder" do
    #   get :mark_as_read
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end
    # works with notifications

    it "should delete notification" do
      get :delete_notification, params: {notification_id: Notification.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should read notification" do
      get :read_notification, params: {notification_id: Notification.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
