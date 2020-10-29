class Admin::PaymentsController < Admin::AdminMasterController
  before_action :require_signin
  require "pubnub"
  Stripe.api_key = ENV['STRIPE_API_KEY']

  def add_payment_account
   if current_user.connected_account_id == ''
   @oauth_url = "https://connect.stripe.com/oauth/authorize?client_id=#{ENV['STRIPE_CLIENT_ID']}&state=#{current_user.stripe_state}&scope=read_write&response_type=code&stripe_user[email]=#{current_user.email}&stripe_user[url]=#{ENV['BASE_URL']}/stripe/oauth"
   else 
    flash.now[:notice] = 'Your payment account has already been added.'
    render :oauth_success_page
   end
   
  end


  def stripe_oauth_redirect
    #to avoid cross site request forgery state must be matched
    state = params[:state]
  if !state_matches?(state)
     flash[:alert_danger] = "State doesn't match. Oauth failed.Please try again later."
     redirect_to admin_add_payment_account_path
  else

  # Send the authorization code to Stripe's API.
  code = params[:code]

  response = Stripe::OAuth.token({
      grant_type: 'authorization_code',
      code: code,
    })
    
  connected_account_id = response.stripe_user_id
  save_account_id(connected_account_id)
  
  flash.now[:notice] = "Your account has been added successfully."
  
   render :oauth_success_page
  end
  end

  def received_payments
    @payments = []
    current_user.received_payments.each do |payment|
      @payments << {
        "id" => payment.id,
        "amount" => payment.amount,
        "created_at" => payment.created_at,
        "payer" => payment.user,
        "event" => payment.ticket.event
      }
    end
    @payments
  end

  def destroy
   if Transaction.find(params[:id]).destroy
    flash[:notice] = "Payement deleted successfully."
    redirect_to admin_payments_received_payments_path
   else
    flash[:alert_danger] = "Payement deletetion failed."
    redirect_to admin_payments_received_payments_path
   end
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def refund_requests
    @refund_requests = current_user.business_refund_requests
  end
  
  def approve_refund
   @refund_request = RefundRequest.find(params[:id])
     if @refund_request.status == "pending" or @refund_request.status == "rejected"
      event_date = Ticket.find(@refund_request.ticket_id).event.start_date.to_date

      diff_in_days = difference_in_days(@refund_request.created_at.to_date, event_date)
      
      refund_amount_percent = ''
      
      if diff_in_days >= 7 then refund_amount_percent = 75 end
      if diff_in_days >= 3 && diff_in_days < 7 then refund_amount_percent = 50 end
      if diff_in_days >= 1 && diff_in_days < 3 then refund_amount_percent = 25 end
      
        transaction = current_user.received_payments.find_by(ticket_id: @refund_request.ticket_id)
        transaction_amount = transaction.amount

        refund_amount = calculate_refund_amount(refund_amount_percent, transaction_amount)

        payment_intent = transaction.payment_intent['id']

        refund = Stripe::Refund.create({
          payment_intent: payment_intent,
          amount: refund_amount.to_i,
          refund_application_fee: true,
        }, {stripe_account: @refund_request.ticket.user.connected_account_id})

        if @refund_request.update!(status: "approved", stripe_refund_response: refund)

          flash[:notice] = "Refund request has been successfully placed."
          redirect_to admin_payments_refund_requests_path     
        else
          flash[:alert_danger] = "Couldn't approved refund request, please try again."
          redirect_to admin_payments_refund_requests_path
        end
      else
        flash[:notice] = "Refund request has already been placed."
        redirect_to admin_payments_refund_requests_path
      end
     end

  def reject_refund
      @refund_request = RefundRequest.find(params[:id])
      if @refund_request.update!(status: 'rejected')
        if @notification = Notification.create(recipient: @refund_request.user, actor: @refund_request.ticket.user, action: get_full_name(@refund_request.ticket.user) + " rejected your refund request.", notifiable: @refund_request, url: '/admin/payments/refund-requests', notification_type: 'mobile', action_type: 'reject_request')  
          @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
          )
  
          @current_push_token = @pubnub.add_channels_to_push(
            push_token: @refund_request.user.device_token,
            type: 'gcm',
            add: @refund_request.user.device_token
            ).value
  
          payload = { 
          "pn_gcm":{
            "notification":{
              "title": get_full_name(@refund_request.ticket.user),
              "body": @notification.action
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
           channel: [@refund_request.user.device_token],
           message: payload
            ) do |envelope|
              puts envelope.status
          end
        end ##notification create

        flash[:notice] = "Refund rejected successfully."
        redirect_to admin_payments_refund_requests_path        
      else
        flash[:alert_danger] = "Refund rejection failed."
        redirect_to admin_payments_refund_requests_path        
      end
  end


  private

  def difference_in_days(start_date, end_date)
    diff = (end_date - start_date).to_i
  end

  def calculate_refund_amount(refund_percent, transaction_amount)
    refund_percent.to_f / 100.0  * transaction_amount.to_f
  end


  def state_matches?(state_parameter)
    # Load the same state value that you randomly generated for your OAuth link.
    saved_state = current_user.stripe_state  
    saved_state == state_parameter
  end

  def save_account_id(id)
    # Save the connected account ID from the response to your database.
    current_user.update!(connected_account_id: id) if current_user
  end

end


