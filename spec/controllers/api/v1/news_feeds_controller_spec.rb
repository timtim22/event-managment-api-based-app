require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::NewsFeedsController, type: :controller do
  describe "Mobile - NewsFeeds API - " do

    before do #not for login API
      request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzI1ODg2fQ.C7f6OoljKzwuW6IIlAYIZ3HPxjRwBg1IhuBnnaV1eP0"
    end

    it "should return business news feeds" do
      post :get_business_news_feeds, params: {business_id: User.web_users.last.id }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
