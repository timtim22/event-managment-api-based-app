require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::CompetitionsController, type: :controller do
  describe "Mobile - Competitions API - " do

    before do #not for login API
      request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzI1ODg2fQ.C7f6OoljKzwuW6IIlAYIZ3HPxjRwBg1IhuBnnaV1eP0"
    end

    it "should return all competitions" do
      post :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should single competitions" do
      post :competition_single, params: {competition_id: Competition.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should let user register in the competition" do
      post :register, params: {competition_id: Competition.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should get competition winner" do
      get :get_winner_and_notify
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should create view" do
      post :create_view, params: {competition_id: Competition.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return business competitions" do
      post :get_business_competitions, params: {business_id: User.web_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
