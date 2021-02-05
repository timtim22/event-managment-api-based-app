require 'rails_helper'
require "spec_helper"


RSpec.describe Dashboard::Api::V1::Users::AuthenticationController, type: :controller do
  describe "GET #login" do


    it "returns login" do
      post :login, params: {email: "test22@test.com", password: "Xerography2!"}
      expect(JSON.parse(response.body)["message"]).to eq("Login is successful.")
    end
  end
end
