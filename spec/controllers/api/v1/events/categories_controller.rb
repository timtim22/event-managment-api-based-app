require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::Events::CategoriesController, type: :controller do
  describe "Mobile - Categories API - " do
    
    before do
      request.headers["Authorization"] =ENV["APP_LOGIN_TOKEN"]
    end 

    it "should get categories" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
