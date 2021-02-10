require 'rails_helper'
require "spec_helper"
 
RSpec.describe Api::V1::Users::UsersController, type: :controller do
  describe "Mobile - User API - " do

    before do
      request.headers["Authorization"] = ENV["APP_LOGIN_TOKEN"]
    end

    puts "token: " + ENV["APP_LOGIN_TOKEN"]

   it "should return all users" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should create users" do
      post :create, params: {
        first_name: "timtim",
        last_name: "hassan",
        dob: "22-05-1995",
        device_token: "anytihng",
        gender: "male",
        is_email_subscribed: "true",
        type: "1",
        role_id: 2,
        email: "taimoor.hassan10@yahoo.com",
        password: "Pakistan2!",
        phone_number: "+923109909077"
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end


   


   it "should update users" do
      put :update_profile, params: {
        id: User.last.id,
        first_name: "timtim - update",
        last_name: "hassan",
        dob: "22-05-1995",
        device_token: "anytihng",
        gender: "male",
        role_id: 2,
        is_email_subscribed: "true",
        type: "1",
        email: "taimoor.hassan10@yahoo.com",
        password: "Pakistan2!",
        phone_number: "+923109909077"
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end



   it "should return profile" do
      get :get_profile
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return profile" do
      post :get_others_profile, params: {user_id: mobile_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return user activity" do
      post :activity_logs, params: {user_id: mobile_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return user attending info" do
      post :attending, params: {user_id: mobile_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return gives_away" do
      post :gives_away, params: {user_id: mobile_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return my activity logs" do
      get :my_activity_logs
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return my attending" do
      get :my_attending
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return my gives away" do
      get :my_gives_away
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should get activity logs" do
      get :get_activity_logs
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should update device token" do
      get :update_device_token, params: {device_token: "anytihng"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should update current location" do
      get :update_current_location, params: {location: "{\"short_address\"=>\"San Jose United States\", \"full_address\"=>\"San Jose, CA, USA\", \"geometry\"=>{\"lat\"=>\"37.4125974\", \"lng\"=>\"-121.9481252\"}}" 
    }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   # it "should update user settings" do
   #    get :update_setting, params: {mute_notifications: true, mute_chat: true}
   #    expect(response).to have_http_status(200)
   #    expect(JSON.parse(response.body)["success"]).to eq(true)
   # end

   it "should get user phone numbers" do
      get :get_phone_numbers
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should get delete user account" do
      get :delete_account, params: {user_id: User.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end
  end

  # describe 'business profile' do

  #     before do
  #         request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMiwiZXhwIjoyMzY1NDE0NDg2fQ.ZVryWeaehp7a435O6dsSozTOrnMxmGTatMw13xEi-ZA"
  #     end

  #     it "should return my business profile" do
  #       get :get_business_profile
  #       expect(response).to have_http_status(200)
  #       expect(JSON.parse(response.body)["success"]).to eq(true)
  #     end


  #     it "should return other business profile" do
  #       get :get_others_business_profile, params: {user_id: business_users.last.id}
  #       expect(response).to have_http_status(200)
  #       expect(JSON.parse(response.body)["success"]).to eq(true)
  #     end
  # end
end
