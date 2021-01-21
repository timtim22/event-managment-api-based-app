require 'rails_helper'
require "spec_helper"


RSpec.describe Dashboard::Api::V1::CompetitionsController, type: :controller do
  describe "Competitions API" do

    before do
      request.headers["Authorization"] = ENV["WEB_LOGIN_TOKEN"]
    end

    it "should return past competitions" do
      get :get_past_competitions
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return all competitions" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should create a competition" do
      post :create, params: {
        title: "New competition for Test",
        description: "description of Test",
        start_date: "13-12-2020",
        end_date: "13-12-2020",
        start_time: "01:01:00",
        end_time: "01:01:00",
        validity: "14-12-2020",
        validity_time: "01:01:00",
        price: "222",
        location:  {
        name: "islamabad",
        geometry: {
          lat: "53.350140",
          lng: "-6.266155"
        }
      },
        terms_conditions: "Terms and condition for Test"
      }

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should update the competition" do
      patch :update, params: {
        id: Competition.last.id,
        title: "New competition for Test - updated",
        description: "description of Test",
        start_date: "13-12-2020",
        end_date: "13-12-2020",
        start_time: "01:01:00",
        end_time: "01:01:00",
        validity: "14-12-2020",
        validity_time: "01:01:00",
        price: "222",
        location:  {
        name: "islamabad",
        geometry: {
          lat: "53.350140",
          lng: "-6.266155"
        }
      },
        terms_conditions: "Terms and condition for Test"
      }

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should destroy the competition" do
      delete :destroy, params: {id: Competition.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
