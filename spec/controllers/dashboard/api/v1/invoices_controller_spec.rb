require 'rails_helper'
require "spec_helper"
require 'spec_web_login'


RSpec.describe Dashboard::Api::V1::InvoicesController, type: :controller do
  describe "Invoices API" do

    it "should return all invoice" do
      get :index
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end

    it "should return an invoice" do
      get :show, params: {id: Invoice.last}
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["success"]).to eq(true)
    end
  end
end
