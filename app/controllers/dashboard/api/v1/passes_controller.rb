class Dashboard::Api::V1::PassesController < Dashboard::Api::V1::ApiMasterController

  # def index
  #   @passes = current_user.passes.order(created_at: "ASC")
  # end

  # def new
  #   @pass = Pass.new
  # end

  # def edit
  #   @pass = Pass.find(params[:id])
  # end

  # def update
  #   @pass = Pass.find(params[:id])
  # end

  # def create
  #   @pass = Pass.new #instantiated to avoid undefine error in case of form errors
  #   ids = params['event_ids']
  #   success = false
  #   if !ids.blank?
  #   ids.each do |id|
  #     @pass = Pass.new
  #     @pass.title = params[:title]
  #     @pass.description = params[:description]
  #     @pass.event_id = id
  #     @pass.user_id = current_user.id,
  #     @pass.redeem_code = params[:redeem_code]
  #     @pass.validity = params[:validity]
  #     if @pass.save
  #       success = true
  #     else
  #       success = false
  #     end
  #   end #each

  #   if success
  #     flash[:notice] = "Pass created successfully."
  #     redirect_to admin_passes_path
  #   else
  #       render :new
  #   end
  # else
  #   flash.now[:alert_danger] = "No event is selected."
  #   render :new
  # end

  # end

  # def destroy
  #   @pass = Pass.find(params[:id])
  # end

  def redeem_it
    if !params[:redeem_code].blank? && !params[:event_id].blank?
     @pass = Pass.find_by(event_id: params[:event_id])
     @check  = Redemption.where(offer_id: @pass.id).where(offer_type: 'Pass').where(user_id: request_user.id)
     if @check.blank?
    if(@pass && @pass.redeem_code == params[:redeem_code].to_s)
      if  @redemption = Redemption.create!(:user_id =>  request_user.id, offer_id: @pass.id, code: params[:redeem_code], offer_type: 'Pass')
      @pass.is_redeemed = true
      @pass.number_of_passes = @pass.number_of_passes - 1;
      @pass.save
        # resource should be parent resource in case of api so that event id should be available in order to show event based interest level.
        #create_activity("redeemed pass", @redemption, 'Redemption', '', @pass.title, 'post')
        #ambassador program: also add earning if the pass is shared by an ambassador
        @shared_offers = []
        @forwardings = OfferForwarding.all.each do |forward|
          @shared_offers.push(forward.offer)
        end

        @sharings = OfferShare.all.each do |share|
          @shared_offers.push(share.offer)
        end

        if @shared_offers.include? @pass
          @share = OfferForwarding.find_by(offer_id: @pass.id)
          if @share.blank?
           @share = OfferShare.find_by(offer_id: @pass.id)
          end
          @ambassador = @share.user
          if @ambassador.is_ambassador ==  true #if user is an ambassador
          @ambassador.earning = @ambassador.earning + @pass.ambassador_rate.to_i
          @ambassador.save
          end
        end

      render json: {
        code: 200,
        success: true,
        message: "Pass redeemed.",
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: "Pass was not redeemed.",
        data: nil
      }
    end
    else
      render json: {
        code: 400,
        success: false,
        message: "Redeem code doesn't match",
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "Pass is already redeemed",
      data: nil
    }
  end
  else
    render json: {
      code: 400,
      success: false,
      message: "event_id and redeem_code are required fields.",
      data: nil
    }
  end
  end

def vip_pass_users
    @profiles = []
      if !params[:event_id].blank?
        e = Event.find(params[:event_id])
        vip = e.passes.first
         @invitees = []
         Wallet.where(offer_id: vip.id).where(offer_type: 'Pass').each do |offer|
          @invitees << {
            user: get_full_name(offer.user),
            Invited: offer.created_at.to_date,
            quantity: offer.quantity,
            Issued_by: get_full_name(request_user),
            Invite: !offer.nil?
            }
          end
              render json: {
              code: 200,
              success: true,
              message: '',
              data:  {
                Invited: @invitees
              }
            }
      else
        render json: {
          code: 400,
          success: false,
          message: 'Event ID is required',
          data: nil
        }
  end
end

def search_users
      @user = []
         profile = Profile.ransack(first_name_or_last_name_start: params[:search_term]).result(distinct:true).page(params[:page]).per(10).order(created_at: "ASC").each do |profile|
          @user << {
              id: profile.user_id,
              user: get_full_name(profile.user),
              invited: "",
              quantity: "",
              Issued_by: "",
              Invite: check_invitation(profile, params[:pass_id])
          }
         end
        render json: {
          code: 200,
          success: true,
          message: 'users',
          data: @user
        }

end

def check_invitation(profile, pass_id)
    if profile.user.wallets.where(offer_id: pass_id).where(offer_type: 'Pass').first.blank?
        false
    else
        true
    end
end

  def send_vip_pass
    if !params[:recipient_id].blank? && !params[:pass_id].blank? && !params[:quantity].blank?
      vip = Pass.find(params[:pass_id])
      user = User.find(params[:recipient_id])
      check  = user.wallets.where(offer_id: vip.id).where(offer_type: 'Pass').first
      if check == nil
       @wallet  = user.wallets.new(offer_id: vip.id, offer_type: 'Pass', quantity: params[:quantity])
      if @wallet.save
         share = vip.vip_pass_shares.create!(user: user)

         vip.quantity = vip.quantity - params[:quantity].to_i
         vip.save

         User.where.not(offer_id: vip.id).where(offer_type: 'Pass').each do |profile|
          @profile << {
            id: profile.user_id,
            user: get_full_name(profile.user),
            invited: "",
            quantity: "",
            Issued_by: "",
            Invite: false
          }
           
         end
         # vip.update(quantity:)
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
         )
             #also notify request_user friends
              if @notification = Notification.create(recipient: user, actor: request_user, action: get_full_name(request_user) + " has sent you a VIP pass to join their event.", notifiable: @wallet.offer, resource: @wallet, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_pass_to_wallet')

              @current_push_token = @pubnub.add_channels_to_push(
                 push_token: user.device_token,
                 type: 'gcm',
                 add: user.device_token
                 ).value

               payload = {
                "pn_gcm":{
                 "notification":{
                   "title": @wallet.offer.title,
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
                channel: user.device_token,
                message: payload
                ) do |envelope|
                    puts envelope.status
               end
            end ##notification create

       # create_activity("added to wallet '#{@wallet.offer.title}'", @wallet, 'Wallet', '', @wallet.offer.title, 'post')
        render json: {
          code: 200,
          success: true,
          message: 'VIP pass sent and added to wallet successfully.',
          data: @profile
        }
      else
        render json: {
          code: 400,
          success: false,
          message: @wallet.errors.full_messages,
          data: nil
        }
      end
    else
      render json:  {
        code: 400,
        success: false,
        message: "Offer is already added.",
        data: nil
      }
    end
    else
      render json: {
        code: 400,
        success: false,
        message: 'recipient_id, pass_id and quantity are requried.',
        data: nil
      }
    end
   end




   def remove_vip_pass
     if !params[:recipient_id].blank?
      vip = Pass.where(pass_type: 'vip').first
      user = User.find(params[:recipient_id]);
      wallet  = user.wallets.where(offer_id: vip.id).where(offer_type: 'Pass').first
      if !wallet.blank?
      if wallet.destroy
        render json: {
          code: 200,
          success: true,
          message: "VIP pass removed successfully.",
          data: nil
        }
      else
        render json: {
          code: 400,
          success: false,
          message: "VIP pass removal failed.",
          data: nil
        }
      end
    else
      render json:  {
        code: 400,
        success: false,
        message: 'No such pass found.',
        data: nil
      }
    end
    else
      render json: {
        code: 400,
        success: false,
        message: 'recipient_id is requried.',
        data: nil
      }
    end

   end


   def vip_people
    vip_people = []
    vip_people = VipPassShare.all.page(params[:page]).per(20).map {|sh|  get_user_object(sh.user) }
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        vip_people: vip_people
      }
    }
   end

  private


  #  def pass_params
  #   params.permit(:title,:description, :validity)
  #  end

end
