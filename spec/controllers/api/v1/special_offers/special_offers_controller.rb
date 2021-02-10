require 'rails_helper'
require "spec_helper"
 


RSpec.describe Api::V1::SpecialOffers::SpecialOffersController, type: :controller do
  describe "Mobile - SpecialOffer API - " do

    before do
      request.headers["Authorization"] =ENV["APP_LOGIN_TOKEN"]
    end

    it "should return all SpecialOffers" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should single SpecialOffer" do
      get :special_offer_single, params: {special_offer_id: SpecialOffer.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return business SpecialOffers" do
      get :get_business_special_offers, params: {business_id: business_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    # it "should return redeem special offer" do
    #   get :redeem_it, params: {redeem_code:d}
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end

    it "should return create SpecialOffers view" do
      get :create_view, params: {offer_id: SpecialOffer.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
