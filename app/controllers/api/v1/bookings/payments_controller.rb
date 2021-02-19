class Api::V1::Bookings::PaymentsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  Stripe.api_key = ENV['STRIPE_API_KEY']

  api :POST, '/api/v1/bookings/purchase-ticket', 'Purchase Ticket'
  param :ticket_id, :number, :desc => "Ticket ID", :required => true
  param :ticket_type, String, :desc => "Type of the ticket", :required => true
  #param :status, ['True', 'False'], :desc => "successful/failed", :required => true
  # param :stripe_response, String, :desc => "Stripe response", :required => true
  # param :transaction_id, :number, :desc => "Transaction ID", :required => true

  def purchase_ticket
    if !params[:ticket_id].blank? && !params[:ticket_type].blank?  && !params[:quantity].blank? && !params[:event_id].blank?
        @ticket = Ticket.find(params[:ticket_id])
        if @ticket.quantity <  params[:quantity].to_i
          render json: {
            code: 400,
            success: false,
            message: 'Wrong quantity is selected.',
            data: nil
          }
          return
        end
        @event = ChildEvent.find(params[:event_id])
      if params[:ticket_type] == 'buy'
        if !params[:status].blank? && !params[:stripe_response].blank? && !params[:transaction_id].blank?

          transaction = Transaction.find(params[:transaction_id]).update!(status: params[:status], stripe_response: params[:stripe_response])


          if(params[:status] == 'successful') #while tikcet_type ==  'buy' 'can_purchase' is already inmpleted  to 'get_secret' api which is the first step of stripe payment, so doesn't need here
            request_user.going_interest_levels.create!(child_event: @event)

              @check = TicketPurchase.where(ticket_id: params[:ticket_id]).where(user_id: request_user.id)
          if @check.blank?
            if @purchase = request_user.ticket_purchases.create!(ticket_id: params[:ticket_id], quantity: params[:quantity], price: @ticket.price)
              #update total quantity
              @ticket.quantity = @ticket.quantity - params[:quantity].to_i
              @ticket.save

              # create_activity(request_user, "attedning event", @event, 'Event', admin_event_path(@event), @event.title, 'post', 'going')

            if @wallet  = request_user.wallets.create!(offer_id: params[:ticket_id], offer_type: 'Ticket')

              @pubnub = Pubnub.new(
                publish_key: ENV['PUBLISH_KEY'],
                subscribe_key: ENV['SUBSCRIBE_KEY']
              )

              if @notification = Notification.create!(recipient: request_user, actor: @purchase.ticket.user, action:  "Ticket you just purchased has been added to your wallet.", notifiable: @wallet.offer, resource: @purchase, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet')

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
                    "actor_image": @notification.actor.avatar,
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

        # create_activity(request_user, "attending event", @event, 'Event', admin_event_path(@event), @event.title, 'post', 'going')

         @wallet = request_user.wallets.where(offer_id: @purchase.id).where(offer_type: 'Ticket').first

      if @wallet

        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
        )

        if @notification = Notification.create!(recipient: request_user, actor: @purchase.ticket.user, action:  "Ticket you just purchased has been added to your wallet.", notifiable: @wallet.offer, resource: @purchase, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet')

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
              "actor_image": @notification.actor.avatar,
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
        if @purchase = request_user.ticket_purchases.create!(ticket_id: params[:ticket_id], quantity: params[:quantity], price: @ticket.price)
          #update total quantity
          @ticket.quantity = @ticket.quantity - params[:quantity].to_i
          @ticket.save

         if @wallet  = request_user.wallets.create!(offer_id: params[:ticket_id], offer_type: 'Ticket')

          @pubnub = Pubnub.new(
            publish_key: ENV['PUBLISH_KEY'],
            subscribe_key: ENV['SUBSCRIBE_KEY']
           )

          if @notification = Notification.create!(recipient: request_user, actor: @purchase.ticket.user, action:  "Ticket you just purchased has been added to your wallet.", notifiable: @wallet.offer, resource: @purchase,  url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet')

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
                "actor_image": @notification.actor.avatar,
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
              "actor_image": @notification.actor.avatar,
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

        transaction = Transaction.find(params[:transaction_id]).update!(status: params[:status], stripe_response: params[:stripe_response])
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
          message: "Your total purchase quantity for this ticket exceeds than allowed per order quantity  #{@ticket.per_head}",
          data: nil
        }
      end
       end #else buy
  else
    render json: {
      code: 400,
      success: false,
      message: "ticket_id, event_id, ticket_type and quantity are required.",
      data: nil
    }
  end
  end

  api :POST, '/api/v1/bookings/create-payment-intent', 'Create payment intent on stripe and get creds'
 param :total_price, String, :desc => "Total Price", :required => true
  param :ticket_id, :number, :desc => "Ticket ID", :required => true
  param :quantity, String, :desc => "Quantity of the tickets", :required => true

  def create_payment_intent
      if !params[:total_price].blank? && !params[:ticket_id].blank? && !params[:quantity].blank?
         application_fee_percent = 5; #later to change it to dynamic value
     @ticket = Ticket.find(params[:ticket_id])
     if can_purchase?(@ticket, params[:quantity])
         @payable = params[:total_price]

         application_fee = calculate_application_fee(@payable.to_i,application_fee_percent).ceil
      if @ticket.user.business_profile.connected_account_id != ''
        intent = Stripe::PaymentIntent.create({
          amount: @payable.to_i * 100,
          currency: 'EUR', #later changeable, will come from admin dashboard
          application_fee_amount:  application_fee,
        }, stripe_account: @ticket.user.connected_account_id)

        #save in db as well

        @transaction = Transaction.create!(user_id: request_user.id, ticket_id: @ticket.id, payment_intent: intent, payee_id: @ticket.user.id, amount: @payable)

    render json: {
      code: 200,
      success: true,
      message: 'Payment Intent successfully created .',
      data: {
        client_secret: intent.client_secret,
        publish_key: ENV['STRIPE_PUBLISH_KEY'],
        transaction_id: @transaction.id,
        account_id: @ticket.user.connected_account_id
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
      message: 'total_price, quantity and ticket_id are required fields.',
      data: nil
    }
  end
  end


  api :POST, '/api/v1/bookings/place-refund-request', 'Place a refund request'
  param :ticket_id, :number, :desc => "Ticket ID", :required => true

  def place_refund_request
    if !params[:ticket_id].blank?
      id = params[:ticket_id]
      @ticket = Ticket.find(id)
    if request_user.refund_requests.create!(business_id: @ticket.user.id, ticket_id: params[:ticket_id], reason: params[:reason])
     render json:  {
       code: 200,
       success: true,
       message: "Refund request successfully placed.",
       data: nil
     }
    else
      render json:  {
        code: 400,
        success: false,
        message: "Refund request placement failed.",
        data: nil
      }
    end
  else
    render json:  {
      code: 400,
      success: false,
      message: "ticket_id is requried field."
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


  def get_stripe_params
    render json: {
      code: 200,
      success: true,
      data: {
        params: params
      }
    }
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
