require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::SettingsController, type: :controller do
  describe "Mobile - Settings API - " do

    before do
      request.headers["Authorization"] = @app_login_token
    end

    it "should purchase ticket" do
      post :update_global_setting, params: {is_on: "true", name: Setting.last.name}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should update user settings" do
      settings = ['mute_chat','mute_notifications','block', 'remove_offers','remove_competitions','remove_passes']
      post :update_user_setting, params: {setting_name: settings.sample, resource_id: Event.last.id, resource_type: "Event", is_on: "false"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should enable/disable user location" do
      status_array = [true, false]
      post :change_location_status, params: {status: status_array.sample }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
