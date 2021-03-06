class Dashboard::Api::V1::InvoicesController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  Stripe.api_key = ENV['STRIPE_API_KEY']

    resource_description do
      api_versions "dashboard"
    end

  api :GET, 'dashboard/api/v1/invoices', 'Get all invoices'

   def index
    @invoices = request_user.invoices.order(id: 'DESC')
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        invoices: @invoices
      }
    }
   end

  api :GET, 'dashboard/api/v1/invoices', 'Get specific invoice'
  param :id, :number, :desc => "Invoice ID", :required => true


   def show
      @invoice = Invoice.find(params[:id])
        invoice = {
          "id" =>  @invoice.id,
          "tax_invoice_number" =>  @invoice.tax_invoice_number,
          "total_amount" => @invoice.total_amount,
          "total_tickets" => @invoice.total_tickets,
          "vat_amount" => @invoice.vat_amount,
          "business_name" => get_full_name(@invoice.user),
          "business_contact" =>  @invoice.user.phone_number
        }

       render json: {
         code: 200,
         success: true,
         message: '',
         data: {
           invoice: invoice
         }
       }

  end


end
