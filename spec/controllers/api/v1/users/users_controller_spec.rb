require 'rails_helper'
require "spec_helper"



# describe "GET #index" do
#     before do
#       get :index
#     end
#     it "returns http success" do
#       expect(response).to have_http_status(:success)
#     end
#     it "JSON body response contains expected recipe attributes" do
#       json_response = JSON.parse(response.body)
#       expect(hash_body.keys).to match_array([:id, :ingredients, :instructions])
<<<<<<< HEAD
#      expect(hash_body).to match({
#      id: article.id,
#     title: 'Hello World'
#expect(body_as_json).to be_kind_of(Hash)
#  })
=======
>>>>>>> event_change
#     end
#   end
 
RSpec.describe Api::V1::Users::UsersController, type: :controller do
  describe "Mobile - User API - " do

    before do
      request.headers["Authorization"] = ENV["APP_LOGIN_TOKEN"]
    end



    #api/v1/users/get-list
   it "should return all users" do
      get :index
      hash_body = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
      expect(hash_body.keys).to match_array([:id, :ingredients, :instructions])
      expect(hash_body.values).to_not be_a_kind_of(NilClass)
   end




   it "should create users" do
      post :create, params: {
        first_name: "timtim",
        last_name: "hassan",
        dob: "22-05-1995",
        gender: "male",
        role_id: 5,
        email: "taimoor.hassan10@yahoo.com",
        password: "Pakistan2!",
        phone_number: "+923109909077",
        location: "Islamabad, Pakistan",
        about: "nothign is real"
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should update users" do
      put :update_profile, params: {
        id: User.last.id,
        first_name: "timtim",
        last_name: "hassan",
        dob: "22-05-1995",
        gender: "male",
        role_id: 5,
        email: "taimoor.hassan10@yahoo.com",
        password: "Pakistan2!",
        phone_number: "+923109909077",
        location: "Islamabad, Pakistan",
        about: "nothign is real"
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end


   it "should return my profile" do
      get :get_profile
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return profile" do
      post :get_others_profile, params: {user_id: User.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return user activity" do
      post :activity_logs, params: {user_id: User.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should return user attending info" do
      post :attending, params: {user_id: User.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end


   it "should return my activity logs" do
      get :my_activity_logs
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
