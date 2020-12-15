require 'rails_helper'
require "spec_helper"
require "spec_app_login"


RSpec.describe Api::V1::AnalyticsController, type: :controller do
  describe "Mobile - Analytics API - " do

    it "should return business stats" do
      post :get_dashboard, params: {business_id: User.web_users.last, resource: "events", current_time_slot_dates: "11-12-2020", before_current_time_slot_dates: "12-12-2020"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
