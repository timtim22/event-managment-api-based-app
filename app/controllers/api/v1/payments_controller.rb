class Api::V1::PaymentsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  Stripe.api_key = ENV['STRIPE_API_KEY']


  def purchase_ticket
    if !params[:ticket_id].blank? && !params[:ticket_type].blank?  && !params[:quantity].blank? 
       if params[:ticket_type] == 'buy'
        if !params[:status].blank? && !params[:stripe_response].blank? && !params[:transaction_id].blank?

          transaction = Transaction.find(params[:transaction_id])
          transaction.status = params[:status]
          transaction.stripe_response = params[:stripe_response]
          transaction.save

          if(transaction.status == 'successful') #while tikcet_type ==  'buy' 'can_purchase' is already inmpleted  to 'get_secret' api which the first step of stripe payment, so doesn't need here
           
            @ticket = Ticket.find(params[:ticket_id])
              @check = TicketPurchase.where(ticket_id: params[:ticket_id]).where(user_id: request_user.id)
          if @check.blank?
            if @purchase = request_user.ticket_purchases.create!(ticket_id: params[:ticket_id], quantity: params[:quantity])
              #update total quantity
              @ticket.quantity = @ticket.quantity - params[:quantity].to_i
              @ticket.save
        
            if @wallet  = request_user.wallets.create!(offer_id: params[:ticket_id], offer_type: 'Ticket')
        
              @pubnub = Pubnub.new(
                publish_key: ENV['PUBLISH_KEY'],
                subscribe_key: ENV['SUBSCRIBE_KEY']
              )
            
              if @notification = Notification.create!(recipient: request_user, actor: @purchase.ticket.user, action:  "Ticket you just purchased has been added to your wallet.", notifiable: @wallet.offer, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet') 
        
                @current_push_token = @pubnub.add_channels_to_push(
                  push_token: request_user.device_token,
                  type: 'gcm',
                  add: request_user.device_token
                  ).value
        
                payload = { 
                  "pn_gcm":{
                  "notification":{
                    "title": @notification.action
                  },
                  data: {
                    "id": @notification.id,
                    "actor_id": @notification.actor_id,
                    "actor_image": @notification.actor.avatar.url,
                    "notifiable_id": @notification.notifiable_id,
                    "notifiable_type": @notification.notifiable_type,
                    "action": @notification.action,
                    "action_type": @notification.action_type,
                    "created_at": @notification.created_at,
                    "body": ''   
                  }
                  }
                }
                @pubnub.publish(
                  channel: request_user.device_token,
                  message: payload
                  ) do |envelope|
                      puts envelope.status
                end
              end ##notification create
            end #if wallet create
  
        render json: {
          code: 200,
          success: true,
          message: "Ticket successfully purchased.",
          data: nil
        }
  
     else
      render json: {
        code: 400,
        success: false,
        message: @purchase.errors.full_messages,
        data: nil
      }
     end
    else
      #here is logic of al ready purchased tikcet but quota is remaining
      @purchase = request_user.ticket_purchases.where(ticket_id: @ticket.id).first
      if @purchased_ticket = @purchase.update!(quantity: @purchase.quantity + params[:quantity].to_i)
        #update total quantity
        @ticket.quantity = @ticket.quantity - params[:quantity].to_i
        @ticket.save

         @wallet = request_user.wallets.where(offer_id: @purchase.id).where(offer_type: 'Ticket').first

      if @wallet 
  
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
        )
      
        if @notification = Notification.create!(recipient: request_user, actor: @purchase.ticket.user, action:  "Ticket you just purchased has been added to your wallet.", notifiable: @wallet.offer, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet') 
  
          @current_push_token = @pubnub.add_channels_to_push(
            push_token: request_user.device_token,
            type: 'gcm',
            add: request_user.device_token
            ).value
  
          payload = { 
            "pn_gcm":{
            "notification":{
              "title": @notification.action
            },
            data: {
              "id": @notification.id,
              "actor_id": @notification.actor_id,
              "actor_image": @notification.actor.avatar.url,
              "notifiable_id": @notification.notifiable_id,
              "notifiable_type": @notification.notifiable_type,
              "action": @notification.action,
              "action_type": @notification.action_type,
              "created_at": @notification.created_at,
              "body": ''   
            }
            }
          }
          @pubnub.publish(
            channel: request_user.device_token,
            message: payload
            ) do |envelope|
                puts envelope.status
          end
        end ##notification create
      end #if wallet create

        render json: {
          code: 200,
          success: true,
          message: "Ticket successfully purchased.",
          data: nil
        }

      else
      render json: {
        code: 400,
        success: false,
        message: @purchase.errors.full_messages,
        data: nil
      }
      end
    end #blank
   
    else
      render json: {
        code: 400,
        success: false,
        message: "Payment is not successful, Please try again later.",
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
       else #buy
        # her will go old logic
        @ticket = Ticket.find(params[:ticket_id])
        if can_purchase?(@ticket, params[:quantity]) 
          @check = TicketPurchase.where(ticket_id: params[:ticket_id]).where(user_id: request_user.id)
        if @check.blank?
        if @purchase = request_user.ticket_purchases.create!(ticket_id: params[:ticket_id], quantity: params[:quantity])
          #update total quantity
          @ticket.quantity = @ticket.quantity - params[:quantity].to_i
          @ticket.save
    
         if @wallet  = request_user.wallets.create!(offer_id: params[:ticket_id], offer_type: 'Ticket')
    
          @pubnub = Pubnub.new(
            publish_key: ENV['PUBLISH_KEY'],
            subscribe_key: ENV['SUBSCRIBE_KEY']
           )
         
          if @notification = Notification.create!(recipient: request_user, actor: @purchase.ticket.user, action:  "Ticket you just purchased has been added to your wallet.", notifiable: @wallet.offer, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet') 
    
            @current_push_token = @pubnub.add_channels_to_push(
               push_token: request_user.device_token,
               type: 'gcm',
               add: request_user.device_token
               ).value
    
             payload = { 
              "pn_gcm":{
               "notification":{
                 "title": @notification.action
               },
               data: {
                "id": @notification.id,
                "actor_id": @notification.actor_id,
                "actor_image": @notification.actor.avatar.url,
                "notifiable_id": @notification.notifiable_id,
                "notifiable_type": @notification.notifiable_type,
                "action": @notification.action,
                "action_type": @notification.action_type,
                "created_at": @notification.created_at,
                "body": ''   
               }
              }
             }
             @pubnub.publish(
              channel: request_user.device_token,
              message: payload
              ) do |envelope|
                  puts envelope.status
             end
          end ##notification create
        end #if wallet create
    
          render json: {
            code: 200,
            success: true,
            message: "Ticket successfully purchased.",
            data: nil
          }
    
       else
        render json: {
          code: 400,
          success: false,
          message: @purchase.errors.full_messages,
          data: nil
        }
       end
      else
      #here is logic of al ready purchased tikcet but quota is remaining
      @purchase = request_user.ticket_purchases.where(ticket_id: @ticket.id).first
      if @purchase_again = @purchase.update!(quantity: @purchase.quantity + params[:quantity].to_i)
        #update total quantity
        @ticket.quantity = @ticket.quantity - params[:quantity].to_i
        @ticket.save

        @wallet = request_user.wallets.where(offer_id: @purchase.id).where(offer_type: 'Ticket').first
  
      if @wallet
  
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
        )
      
        if @notification = Notification.create!(recipient: request_user, actor: @purchase.ticket.user, action:  "Ticket you just purchased has been added to your wallet.", notifiable: @wallet.offer, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet') 
  
          @current_push_token = @pubnub.add_channels_to_push(
            push_token: request_user.device_token,
            type: 'gcm',
            add: request_user.device_token
            ).value
  
          payload = { 
            "pn_gcm":{
            "notification":{
              "title": @notification.action
            },
            data: {
              "id": @notification.id,
              "actor_id": @notification.actor_id,
              "actor_image": @notification.actor.avatar.url,
              "notifiable_id": @notification.notifiable_id,
              "notifiable_type": @notification.notifiable_type,
              "action": @notification.action,
              "action_type": @notification.action_type,
              "created_at": @notification.created_at,
              "body": ''   
            }
            }
          }
          @pubnub.publish(
            channel: request_user.device_token,
            message: payload
            ) do |envelope|
                puts envelope.status
          end
        end ##notification create
      end #if wallet create

        render json: {
          code: 200,
          success: true,
          message: "Ticket successfully purchased.",
          data: nil
        }

      else
      render json: {
        code: 400,
        success: false,
        message: @purchase.errors.full_messages,
        data: nil
      }
      end
      end
      else
        render json: {
          code: 400,
          success: false,
          message: "Your total purchase quantity for this ticket exceeds than allowed per head quantity  #{@ticket.per_head}",
          data: nil
        }
      end
       end #else buy
  else
    render json: {
      code: 400,
      success: false,
      message: "ticket_id, ticket_type and quantity are required.",
      data: nil
    }
  end
  end

  def get_secret
      if !params[:currency].blank? && !params[:ticket_id].blank? && !params[:quantity].blank?
        application_fee_percent = 5;

   @ticket = Ticket.find(params[:ticket_id])
     if can_purchase?(@ticket, params[:quantity]) 
         @payable = @ticket.price * params[:quantity].to_i
         application_fee = calculate_application_fee(@payable,application_fee_percent).ceil
      if @ticket.user.connected_account_id != 'no account' 
        intent = Stripe::PaymentIntent.create({
          amount: @payable,
          currency: params[:currency], #later changeable, will come from admin dashboard
          application_fee_amount:  application_fee,
        }, stripe_account: @ticket.user.connected_account_id)

        #save in db as well
        current_amount = @ticket.price - application_fee
        @transaction = Transaction.create!(user_id: request_user.id, ticket_id: @ticket.id, payment_intent: intent, payee_id: @tikcet.user.id, amount: current_amount)

    render json: {
      code: 200,
      success: true,
      message: 'Payment Intent successfully created .',
      data: {
        client_secret: intent.client_secret,
        publish_key: ENV['STRIPE_PUBLISH_KEY'],
        transaction_id: @transaction.id
      }
    }
  else
    render json: {
      code: 400,
      success: false,
      message: "The tikcet owner doesn't have any added stripe account.",
      data: nil
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: "Your total purchase quantity for this ticket exceeds than allowed per head quantity  #{@ticket.per_head}",
      data: nil
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: 'currency, quantity and ticket_id are required fields.',
      data: nil
    }
  end
  end

  # def confirm_payment
  #   if !params[:status].blank? && !params[:stripe_response].blank? && !params[:transaction_id].blank?
  #      transaction = Transaction.find(params[:transaction_id])
  #      transaction.status = params[:status]
  #      transaction.stripe_response = params[:stripe_response]
  #      transaction.save
  #   render json: {
  #      code: 200,
  #      success: true,
  #      message: 'payment confirmation update is successful.',
  #      data: nil
  #    }
  #   else
  #     render json: {
  #       code: 400,
  #       success: false,
  #       message: 'status, transaction_id and stripe response are required fields.',
  #       data: nil
  #     }
  #   end
  # end

  private

  def calculate_application_fee(amount, application_fee_percent)
   application_fee = application_fee_percent.to_f  / 100.0 * amount.to_f
  end 
  
  #check if a user can purchase a ticket
  def can_purchase?(ticket, purchase_quantity)
    purchased_ticket = request_user.ticket_purchases.where(ticket_id: ticket.id).first
    if purchased_ticket.blank? #buying first time?
    if purchase_quantity.to_i <= @ticket.per_head && purchase_quantity.to_i > 0
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
