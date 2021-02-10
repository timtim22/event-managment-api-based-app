require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::Businesses::BusinessDashboardController, type: :controller do
  describe "Mobile - BusinessDashboard API - " do

    before do
      request.headers["Authorization"] =ENV["WEB_LOGIN_TOKEN"]
    end

    it "should get business details" do
      get :home
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should get events details" do
      get :events
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should get special offers details" do
      get :special_offers
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should get competitions details" do
      get :competitions
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
