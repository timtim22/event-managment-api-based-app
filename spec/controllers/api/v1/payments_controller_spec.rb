require 'rails_helper'
require "spec_helper"
require "spec_app_login"


RSpec.describe Api::V1::PaymentsController, type: :controller do
  describe "Mobile - Passes API - " do

    it "should purchase ticket" do
      post :purchase_ticket, params: {ticket_id: Ticket.last.id, ticket_type: Ticket.last.ticket_type, quantity: 1}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    # it "should get secret" do
    #   post :get_secret, params: {ticket_id: Ticket.last.id, ticket_type: Ticket.last.ticket_type, quantity: 1, total_price: 1.1}
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end

    it "should palce refund request" do
      post :place_refund_request, params: {ticket_id: Ticket.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

  end
end
