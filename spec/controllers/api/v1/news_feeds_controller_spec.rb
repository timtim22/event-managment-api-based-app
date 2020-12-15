require 'rails_helper'
require "spec_helper"
require "spec_app_login"


RSpec.describe Api::V1::NewsFeedsController, type: :controller do
  describe "Mobile - NewsFeeds API - " do

    it "should return business news feeds" do
      post :get_business_news_feeds, params: {business_id: User.web_users.last.id }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
