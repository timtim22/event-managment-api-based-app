require 'rails_helper'
require "spec_helper"

RSpec.describe Api::V1::::Ambassadors::AmbassadorsController, type: :controller do
  describe "Mobile - Ambassadors API - " do
   
    before do
      request.headers["Authorization"] =ENV["APP_LOGIN_TOKEN"]
    end

    it "should send ambassador request to business user" do
      get :send_request, params: {:business_id => business_users.last}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should reutn all business accounts" do
      get :businesses_list
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return only ambassador's business accounts " do
      get :my_businesses
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

   
  end
end
