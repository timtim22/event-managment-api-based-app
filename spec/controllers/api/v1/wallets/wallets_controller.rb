require 'rails_helper'
require "spec_helper"
 


RSpec.describe Api::V1::Wallets::WalletsController, type: :controller do
  describe "Mobile - Wallet API - " do
    
    before do
      request.headers["Authorization"] =ENV["APP_LOGIN_TOKEN"]
    end

   it "should get offers from wallet" do
      get :get_offers
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should get passes from wallet" do
      get :get_passes
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should get competitions from wallet" do
      get :get_competitions
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should get tickets from wallet" do
      get :get_tickets
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should remove offer from wallet" do
      get :remove_offer, params: {offer_id: Wallet.last.offer_id, offer_type: Wallet.last.offer_type}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should add offer to wallet" do
      get :add_to_wallet, params: {offer_id: SpecialOffer.last.id, offer_type: "SpecialOffer"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

   it "should view offer" do
      get :view_offer, params: {offer_id: SpecialOffer.last.id, offer_type: "SpecialOffer"}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end
 end
end
