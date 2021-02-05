require 'rails_helper'
require "spec_helper"

RSpec.describe Dashboard::Api::V1::Users::UsersController, type: :controller do
  describe "User API" do

    before do
      request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo1LCJleHAiOjIzNjgzNDg4NDd9.SqgUyBqC0tkGopadOOw2hNSMww8ePDbsbJXcDlsQYqw"
    end


    it "should return all users" do
      get :show_all_users
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return a specific user" do
      get :get_user, params: {user_id: Assignment.where(role_id: 2).last.user.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should create a user" do
      post :create_user, params: {
        profile_name: "timtim",
        contact_name: "timtim - contact_name",
        location: "Islamabad",
        display_name: "timtim - display_name",
        phone_number: "+923109909077",
        email: "test111@test.com",
        password: "Xerography2!",
        is_charity: true,
        about: "timtim -about",
        is_subscribed: false,
        about: "nothing is real",
        website: "www.googl.com",
        vat_number: "12344",
        charity_number: "12344",
        youtube: "www.youtube.com",
        facebook: "www.facebook.com",
        linkedin: "www.linkedin.com",
        twitter: "www.twitter.com",
        snapchat: "www.snapchat.com",
        role_id: 5
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should update the user" do
      put :update_user, params: {
        user_id: Assignment.where(role_id: 2).last.user.id,
        profile_name: "timtim updated",
        contact_name: "timtim - contact_name",
        location: "Islamabad",
        display_name: "timtim - display_name",
        phone_number: "+923109909077",
        email: "test111@test.com",
        password: "Xerography2!",
        is_charity: true,
        about: "timtim -about",
        is_subscribed: false,
        about: "nothing is real",
        website: "www.googl.com",
        vat_number: "12344",
        charity_number: "12344",
        youtube: "www.youtube.com",
        facebook: "www.facebook.com",
        linkedin: "www.linkedin.com",
        twitter: "www.twitter.com",
        snapchat: "www.snapchat.com",
        role_id: 5
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
