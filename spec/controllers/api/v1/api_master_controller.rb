require 'rails_helper'
require "spec_helper"

RSpec.describe Api::V1::ApiMasterController, type: :controller do
  describe "Mobile - Api master controller - " do
   
    before do
      request.headers["Authorization"] =ENV["APP_LOGIN_TOKEN"]
    end

    it "should create an impression for the submitted model" do
      post :create_impression, params: {:resource_id => ChildEvent.last.id, resource_type: "ChildEvent"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
