require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::AuthenticationController, type: :controller do
  describe "Mobile - Authentication API - " do

    before do
      request.headers["Authorization"] = ENV["APP_LOGIN_TOKEN"]
    end

    it "should login" do
      post :login, params: {id: User.app_users.last, device_token: "firebase_device_token"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return accounts" do
      post :get_accounts, params: {phone_number: User.app_users.last.phone_number}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should logout user and clear push token from pubnub push channel" do
      post :logout
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    # it "should verify code" do
    #   post :verify_code, params: {email: "priboy@gmail.co", verification_code: "asdsda"}
    #   # expect(response).to have_http_status(200)
    #   # expect(subject).to render_template("user_mailer/verifciation_redirect_page")
    #   expect(view).to render_template("user_mailer/verifciation_redirect_page")
    # end

    it "should update password" do
      post :update_password, params: {email: User.app_users.last.email, password: "asdasd"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
