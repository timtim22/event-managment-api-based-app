require 'rails_helper'
require "spec_helper"


RSpec.describe Dashboard::Api::V1::PaymentsController, type: :controller do
  describe "Payment API" do
    before do
      request.headers["Authorization"] = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMiwiZXhwIjoyMzY0OTgxNzYxfQ.Dq_FXVHsg5OeEuLS8zSTPb-VI7vGgsc-NuYvQNKWR7c"
    end

    it "should create payment intent" do
      post :create_intant, params: {
        price: 22
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should confirm payment" do
      post :confirm_payment, params: {
        status: "successful",
        stripe_response: "successful",
        total_tickets: 22,
        vat_amount: 22,
        transaction_id: 1,
      }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
