require 'rails_helper'
require "spec_helper"
require "spec_app_login"


RSpec.describe Api::V1::SettingsController, type: :controller do
  describe "Mobile - Settings API - " do

    it "should purchase ticket" do
      post :update_global_setting, params: {is_on: "true", name: Setting.last.name}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should update user settings" do
      post :update_user_setting, params: {setting_name: UserSetting.last.name, resource_id: 11, resource_type: "Event", is_on: "false"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
