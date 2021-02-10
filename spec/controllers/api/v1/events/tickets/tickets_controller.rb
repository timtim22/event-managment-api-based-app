require 'rails_helper'
require "spec_helper"
 


RSpec.describe Api::V1::Events::Tickets::TicketsController, type: :controller do
  describe "Mobile - Tickets API - " do

    before do
      request.headers["Authorization"] =ENV["APP_LOGIN_TOKEN"]
    end

    # it "should redeem ticket" do
    #   get :redeem_it
    #   expect(response).to have_http_status(200)
    #   expect(JSON.parse(response.body)["success"]).to eq(true)
    # end

   it "should return tickets for events" do
      get :get_tickets, params: {event_id: Event.last.id}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
   end

  end
end
