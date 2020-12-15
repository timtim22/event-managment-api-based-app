require 'rails_helper'
require "spec_helper"
require "spec_app_login"

RSpec.describe Api::V1::AmbassadorsController, type: :controller do
  describe "Mobile - Ambassadors API - " do


    it "should send ambassador request to business user" do
      get :send_request, params: {:business_id => User.web_users.last}
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

  end
end
