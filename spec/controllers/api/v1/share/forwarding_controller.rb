require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::Share::ForwardingController, type: :controller do
  describe "Mobile - Fowarding API - " do
   
    before do
      request.headers["Authorization"] =ENV["APP_LOGIN_TOKEN"]
    end

    it "should forward offer" do
      post :forward_offer, params: {offer_id: OfferForwarding.last.offer_id, offer_type: OfferForwarding.last.offer_type, user_ids: mobile_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should share offer" do
      post :share_offer, params: {
        offer_shared: "true",
        sender_token:ENV["APP_LOGIN_TOKEN"],
        offer_type: OfferForwarding.last.offer_type,
        offer_id: OfferForwarding.last.offer_id
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should forward event" do
      post :forward_event, params: {child_event_id: ChildEvent.last.id, user_ids: mobile_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should share event" do
      post :share_event, params: {
        event_shared: "true",
        sender_token:ENV["APP_LOGIN_TOKEN"],
        child_event_id: ChildEvent.last.id
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end


  it "should ask location" do
    get :ask_location, params: {askee_ids: mobile_users.last.id}
    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)["success"]).to eq(true)
  end

  # it "should get location" do
  #   get :get_location, params: {
  #     lat: Profile.last.lat,
  #     lat: Profile.last.lng,
  #     asker_id: mobile_users.last.id
  #   }
  #   expect(response).to have_http_status(200)
  #   expect(JSON.parse(response.body)["success"]).to eq(true)
  # end
  #works with notifications

  # it "should send location" do
  #   get :send_location, params: {
  #     lat: Profile.last.lat,
  #     lat: Profile.last.lng,
  #     asker_id: mobile_users.last.id
  #   }
  #   expect(response).to have_http_status(200)
  #   expect(JSON.parse(response.body)["success"]).to eq(true)
  # end
  # works with notifications

end
