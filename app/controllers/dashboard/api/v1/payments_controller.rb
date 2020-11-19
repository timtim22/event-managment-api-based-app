class Dashboard::Api::V1::PaymentsController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  Stripe.api_key = ENV['STRIPE_API_KEY']


    def create_intant
      if !params[:price].blank? 
         application_fee = 0; #later to change it to dynamic value
         @payable = params[:price]
        intent = Stripe::PaymentIntent.create({
          amount: @payable.to_i * 100,
          currency: 'EUR', #later changeable, will come from admin dashboard
          application_fee_amount:  application_fee,
        }, stripe_account: "acct_1Bvu6OGEPRyMxxO2")

        #save in db as well
        @transaction = Transaction.create!(user_id: request_user.id, ticket_id: 0, payment_intent: intent, payee_id: 0, amount: @payable)

    render json: {
      code: 200,
      success: true,
      message: 'Payment Intent successfully created .',
      data: {
        client_secret: intent.client_secret,
        publish_key: ENV['STRIPE_PUBLISH_KEY'],
        transaction_id: @transaction.id,
        account_id: 'acct_1Bvu6OGEPRyMxxO2' #mygo operations account
      }
    }

  else
    render json: {
      code: 400,
      success: false,
      message: 'price is required field.',
      data: nil
    }
  end
 end



 
 
 def confirm_payment
  if !params[:status].blank? && !params[:stripe_response].blank? && !params[:transaction_id].blank?
    transaction = Transaction.find(params[:transaction_id])
    if transaction.update!(status: params[:status], stripe_response: params[:stripe_response])
    render json: {
      code: 200,
      success: true,
      message: "Payment is successful.",
      data: nil
    }
  else
    render json: {
      code: 400,
      success: false,
      message: "Payment confirmation failed.",
      data: nil
    }
  end
  else
    render json: {
        code: 400,
        status: false,
        message: 'status, stripe_response and transaction_id are required fields.',
        data: nil
      }
  end
 end







 def get_stripe_params
    render json: {
      code: 200,
      success: true,
      data: {
        params: params
      }
    }
  end


  
  def get_invoice
    if !params[:transaction_id].blank?
           
      @transaction = Transaction.find(params[:transaction_id])
        invoice = {
          "id" => transaction_id,
          "Ticket Event" => @transaction.amount
        }
     
       render json: {
         code: 200,
         success: true,
         message: '',
         data: {
           invoice: invoice
         }
       }
    else
      render json: {
        code: 400,
        success: false,
        message: "transaction_id is required field.",
        data: nil
      }
    end
  end



  private
  def calculate_application_fee(amount, application_fee_percent)
   application_fee = application_fee_percent.to_f  / 100.0 * amount.to_f
  end 
  
  #check if a user can purchase a ticket
  def can_purchase?(ticket, purchase_quantity)
    purchased_ticket = request_user.ticket_purchases.where(ticket_id: ticket.id).first
    if purchased_ticket.blank? #buying first time?
    if purchase_quantity.to_i > 0 && purchase_quantity.to_i <= @ticket.per_head  
      true
    else
      false
    end 
  else
   #check if user has finished purchase quota
   if purchased_ticket.quantity + purchase_quantity.to_i <= ticket.per_head
     true
   else
    false
   end
  end #blank
  end
  
end