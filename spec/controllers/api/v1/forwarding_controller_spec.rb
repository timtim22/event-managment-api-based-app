require 'rails_helper'
require "spec_helper"


RSpec.describe Api::V1::ForwardingController, type: :controller do
  describe "Mobile - Fowarding API - " do

    before do #not for login API
      request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzI1ODg2fQ.C7f6OoljKzwuW6IIlAYIZ3HPxjRwBg1IhuBnnaV1eP0"
    end

    it "should forward offer" do
      post :forward_offer, params: {offer_id: OfferForwarding.last.offer_id, offer_type: OfferForwarding.last.offer_type, user_ids: User.app_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should share offer" do
      post :share_offer, params: {
        offer_shared: "true",
        sender_token: "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzI1ODg2fQ.C7f6OoljKzwuW6IIlAYIZ3HPxjRwBg1IhuBnnaV1eP0",
        offer_type: OfferForwarding.last.offer_type,
        offer_id: OfferForwarding.last.offer_id
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should forward event" do
      post :forward_event, params: {event_id: Event.last.id, user_ids: User.app_users.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should share event" do
      post :share_event, params: {
        event_shared: "true",
        sender_token: "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMSwiZXhwIjoyMzY1MzI1ODg2fQ.C7f6OoljKzwuW6IIlAYIZ3HPxjRwBg1IhuBnnaV1eP0",
        event_id: Event.last.id
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
