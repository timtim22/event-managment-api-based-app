require 'rails_helper'
require "spec_helper"
require 'spec_authentication'

RSpec.describe Dashboard::Api::V1::UsersController, type: :controller do
  describe "SpecialOffer API" do

    before do
      request.headers["Authorization"] = @dashboard_login_token
    end


    it "should return all users" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return a specific user" do
      get :show, params: {id: User.web_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should create a user" do
      post :create, params: {
        profile_name: "timtim",
        contact_name: "timtim - contact_name",
        address: "Islamabad",
        display_name: "timtim - display_name",
        phone_number: "+923109909077",
        email: "taimoor.hassan10@yahoo.com",
        password: "Xerography2!",
        is_charity: "true",
        about: "timtim -about"
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should update the user" do
      put :update, params: {
        id: User.web_users.last,
        profile_name: "timtim",
        contact_name: "timtim - contact_name",
        address: "Islamabad",
        display_name: "timtim - display_name",
        phone_number: "+923109909077",
        email: "taimoor.hassan10@yahoo.com",
        password: "Xerography2!",
        is_charity: "true",
        about: "timtim -about"
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
