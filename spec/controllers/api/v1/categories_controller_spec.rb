require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::CategoriesController, type: :controller do
  describe "Mobile - Categories API - " do

    it "should get categories" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
