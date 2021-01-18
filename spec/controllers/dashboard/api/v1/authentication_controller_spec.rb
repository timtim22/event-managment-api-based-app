require 'rails_helper'
require "spec_helper"


RSpec.describe Dashboard::Api::V1::AuthenticationController, type: :controller do
  describe "GET #login" do


    it "returns http success" do
      post :login, params: {email: User.web_users.last.email, password: "Secret@123"}
      expect(JSON.parse(response.body)["message"]).to eq("Login is successful.")
    end
  end
end
