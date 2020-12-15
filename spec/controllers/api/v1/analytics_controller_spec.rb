require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::AnalyticsController, type: :controller do
  describe "Mobile - Analytics API - " do

    before do
      request.headers["Authorization"] = @app_login_token
    end

    it "should return business stats" do
      post :get_dashboard, params: {business_id: User.web_users.last, resource: "events", current_time_slot_dates: "11-12-2020", before_current_time_slot_dates: "12-12-2020"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return special offers stats" do
      post :get_offer_stats, params: { special_offer_id: SpecialOffer.last.id, time_slot_dates: '2020-11-30,2020-11-28' }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
