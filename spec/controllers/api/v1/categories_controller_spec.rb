require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::CategoriesController, type: :controller do
  describe "Mobile - Categories API - " do

    # before do #not for login API
    #   request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMiwiZXhwIjoyMzY1MzE0MDI1fQ.ST9BF1XMUOMvvJ42ruT1Qq1p_kb21d_o-rZVdXS0LVU"
    # end

    it "should get categories" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
