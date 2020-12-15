require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::PassesController, type: :controller do
  describe "Mobile - Passes API - " do

    before do
      request.headers["Authorization"] = @app_login_token
    end

    it "should return all passes" do
      get :index, params: {event_id: Event.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return single pass" do
      get :pass_single, params: {pass_id: Pass.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    # it "should redeem the pass pass" do
    #   get :redeem_it, params: {pass_id: Pass.last.id, redeem_code: Redemption.last.code}
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end

    it "should create pass view" do
      get :create_view, params: {pass_id: Pass.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
