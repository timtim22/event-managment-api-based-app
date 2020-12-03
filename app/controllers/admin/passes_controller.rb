class Admin::PassesController < Admin::AdminMasterController
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  require 'rqrcode'

  before_action :require_signin
  def index
    @passes = current_user.passes.order(created_at: "DESC")
  end

  def new
    @pass = Pass.new
  end

  def show
    @pass = Pass.find(params[:id])
  end

  def edit
    @pass = Pass.find(params[:id])
  end

  def update
    ids = params['event_ids']
    success = false
    if !ids.blank?
    ids.each do |id|
      @pass = Pass.find_by(event_id: id)
      if @pass.blank?
        @pass = Pass.new
      end
      @pass.title = params[:title]
      @pass.description = params[:description]
      @pass.event_id = id
      @pass.validity = string_to_DateTime(params[:validity])
      @pass.quantity = params[:quantity]
      @pass.pass_type = params[:pass_type]
      @pass.validity_time = params[:validity_time]
      @pass.terms_conditions = params[:terms_conditions]
      if @pass.save
        #create_activity("updated pass", @pass, "Pass", admin_pass_path(@pass),@pass.title, 'patch')
        success = true
      else
        success = false
      end
    end #each

    if success
      flash[:notice] = "pass updated successfully."
      redirect_to admin_passes_path
    else
        render :edit
    end
  else
    flash.now[:alert_danger] = "No event is selected."
    render :new
  end

  end


  def create
    @pass = Pass.new #instantiated to avoid undefine error in case of form errors
    ids = params['event_ids']
    success = false
    if !ids.blank?
    @pubnub = Pubnub.new(
      publish_key: ENV['PUBLISH_KEY'],
      subscribe_key: ENV['SUBSCRIBE_KEY']
      )
    ids.each do |id|

      @pass = Pass.new
      @pass.title = params[:title]
      @pass.description = params[:description]
      @pass.event_id = id
      @pass.user = current_user
      @pass.redeem_code = generate_code
      @pass.quantity = params[:quantity]
      @pass.validity = string_to_DateTime(params[:validity])
      @pass.pass_type = params[:pass_type]
      @pass.validity_time = params[:validity_time]
      @pass.terms_conditions = params[:terms_conditions]
      @event = Event.find(id)
      @event.pass = 'true'
      if @pass.save && @event.save
       # create_activity("created pass", @pass, "Pass", admin_pass_path(@pass),@pass.title, 'post')
        if !current_user.followers.blank?
          current_user.followers.each do |follower|
      if follower.passes_notifications_setting.is_on == true
        if @notification = Notification.create!(recipient: follower, actor: current_user, action: get_full_name(current_user) + " created a new pass '#{@pass.title}'.", notifiable: @pass, resource: @pass, url: "/admin/passes/#{@pass.id}", notification_type: 'mobile', action_type: 'create_pass')

          @current_push_token = @pubnub.add_channels_to_push(
           push_token: follower.profile.device_token,
           type: 'gcm',
           add: follower.profile.device_token
           ).value

           payload = {
            "pn_gcm":{
             "notification":{
               "title": get_full_name(current_user),
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
              "body": '',
              "is_added_to_wallet": added_to_wallet?(notification.resource)
             }
            }
           }

         @pubnub.publish(
           channel: follower.profile.device_token,
           message: payload
           ) do |envelope|
               puts envelope.status
          end
         end # notificatiob end
        end # passes setting
        end #each
        end # not blank
        success = true
      else
        success = false
      end
    end #each

    if success
      flash[:notice] = "Pass created successfully."
      redirect_to admin_passes_path
    else
        render :new
    end
  else
    flash.now[:alert_danger] = "No event is selected."
    render :new
  end

  end

  # def destroy
  #   @pass = Pass.find(params[:id])
  # end

  # def redeem_it
  #   @pass = Pass.find_by(event_id: params[:event_id])
  #   if(@pass.redeem_code == params[:code])
      #@redemption = @pass.redemption.create!(:user_id =>  current_user.id, code: params[:code])
  #   else
  #
  #   end

  # end

  def destroy
    @pass = Pass.find(params[:id])
    if @pass.destroy
      #create_activity("deleted pass", @pass, "Pass", '', @pass.title, 'delete')
      redirect_to admin_passes_path, notice: "Pass deleted successfully."
    else
      flash[:alert_danger] = "Pass deletetion failed."
      redirect_to admin_passes_path
    end
  end


  def send_vip_pass_page
    @users = User.app_users
  end


  # def send_vip_pass
  #   if !params[:user_ids].blank?
  #     vip = Pass.where(pass_type: 'vip').first
  #     user_ids = params[:user_ids]
  #     user_ids.each  do  |id|
  #     user = User.find(id);
  #     check  = user.wallets.where(offer_id: vip.id).where(offer_type: 'Pass').first
  #     if check == nil
  #      @wallet  = user.wallets.new(offer_id: vip.id, offer_type: 'Pass')
  #     if @wallet.save
  #        share = vip.vip_pass_shares.create!(user: user)
  #       @pubnub = Pubnub.new(
  #         publish_key: ENV['PUBLISH_KEY'],
  #         subscribe_key: ENV['SUBSCRIBE_KEY']
  #        )
  #            #also notify current_user friends
  #             if @notification = Notification.create(recipient: user, actor: current_user, action: get_full_name(current_user) + " has sent you a VIP pass to join their event.", notifiable: @wallet.offer, url: "/admin/#{@wallet.offer.class.name.downcase}s/#{@wallet.offer.id}", notification_type: 'mobile', action_type: 'add_to_wallet')

  #             @current_push_token = @pubnub.add_channels_to_push(
  #                push_token: user.profile.device_token,
  #                type: 'gcm',
  #                add: user.profile.device_token
  #                ).value

  #              payload = {
  #               "pn_gcm":{
  #                "notification":{
  #                  "title": @wallet.offer.title,
  #                  "body": @notification.action
  #                },
  #                data: {
  #                 "id": @notification.id,
  #                 "actor_id": @notification.actor_id,
  #                 "actor_image": @notification.actor.avatar,
  #                 "notifiable_id": @notification.notifiable_id,
  #                 "notifiable_type": @notification.notifiable_type,
  #                 "action": @notification.action,
  #                 "action_type": @notification.action_type,
  #                 "created_at": @notification.created_at,
  #                 "body": ''
  #                }
  #               }
  #              }
  #              @pubnub.publish(
  #               channel: user.profile.device_token,
  #               message: payload
  #               ) do |envelope|
  #                   puts envelope.status
  #              end
  #           end ##notification create
  #         end #each

  #      # create_activity("added to wallet '#{@wallet.offer.title}'", @wallet, 'Wallet', '', @wallet.offer.title, 'post')
  #      flash[:notice] = "Pass successfully sent."
  #      redirect_to admin_passes_path
  #     else
  #       flash[:alert_danger] = @wallet.errors.full_messages
  #       redirect_to admin_passes_path
  #     end
  #   else
  #     flash[:alert_danger] = "Pass is already shared."
  #     redirect_to admin_passes_path
  #   end

  #   else
  #    flash[:alert_danger] = "user_id is required."
  #    redirect_to admin_passes_path
  #   end
  #  end






  private
   def pass_params
    params.permit(:title,:description, :validity,:user_id, :pass_type)
   end



end
