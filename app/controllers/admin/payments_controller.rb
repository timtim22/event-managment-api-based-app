class Admin::PaymentsController < Admin::AdminMasterController
  before_action :require_signin

  Stripe.api_key = ENV['STRIPE_API_KEY']

  def add_payment_account
   if current_user.connected_account_id == 'no account'
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
  end

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
    
  end


  private

  def state_matches?(state_parameter)
    # Load the same state value that you randomly generated for your OAuth link.
    saved_state = current_user.stripe_state  
    saved_state == state_parameter
  end

  def save_account_id(id)
    # Save the connected account ID from the response to your database.
    current_user.update!(connected_account_id: id)
  end

end


