require 'rails_helper'
require "spec_helper"
require "spec_authentication"


RSpec.describe Api::V1::NewsFeedsController, type: :controller do
  describe "Mobile - NewsFeeds API - " do
    
    before do
      request.headers["Authorization"] = @app_login_token
    end

    it "should return business news feeds" do
      post :get_business_news_feeds, params: {business_id: User.web_users.last.id }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
