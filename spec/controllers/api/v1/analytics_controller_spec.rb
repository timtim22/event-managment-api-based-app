require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::AnalyticsController, type: :controller do
  describe "Mobile - Analytics API - " do

    before do
      request.headers["Authorization"] = ENV["APP_LOGIN_TOKEN"]
    end

    it "should return business stats" do
      post :get_dashboard, params: {business_id: User.web_users.last, resource: "events", current_time_slot_dates: "2020-11-11", before_current_time_slot_dates: "2020-12-12"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return special offers stats" do
      post :get_offer_stats, params: { 
        offer_id: SpecialOffer.last.id, 
        frequency: 'daily', 
        date: '2021-02-11' 
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return competitiion stats" do
      post :get_competition_stats, params: { 
        competition_id: Competition.last.id, 
        frequency: 'daily', 
        date: '2021-02-11' 
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
