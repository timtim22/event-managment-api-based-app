require 'rails_helper'
require "spec_helper"
require 'spec_authentication'


RSpec.describe Dashboard::Api::V1::DashboardController, type: :controller do
  describe "GET Dashboard Stats" do

    before do
      request.headers["Authorization"] = ENV["WEB_LOGIN_TOKEN"]
    end

    it "returns http success" do
      get :get_dashboard_stats, params: {business_id: User.web_users.last.id, current_time_slot_dates: "04-11-2020, 09-12-2020, 12-12-2020"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["code"]).to eq(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
      expect(JSON.parse(response.body)["message"]).to eq("Dashboard Stats")
    end
  end
end
