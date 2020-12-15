require 'rails_helper'
require "spec_helper"
require 'spec_web_login'


RSpec.describe Dashboard::Api::V1::PaymentsController, type: :controller do
  describe "Payment API" do

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
