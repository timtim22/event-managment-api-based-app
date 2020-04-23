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
      @pass.title = params[:title]
      @pass.description = params[:description]
      @pass.event_id = id
      @pass.validity = params[:validity]
      @pass.number_of_passes = params[:no_of_passes]
      @pass.validity_time = params[:validity_time]
      @pass.ambassador_name = params[:ambassador_name]
      @pass.terms_conditions = params[:terms_conditions]
      if @pass.save
        create_activity("updated pass", @pass, "Pass", admin_pass_path(@pass),@pass.title, 'patch')
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
      @pass.number_of_passes = params[:no_of_passes]
      @pass.validity = params[:validity]
      @pass.validity_time = params[:validity_time]
      @pass.ambassador_name = params[:ambassador_name]
      @pass.terms_conditions = params[:terms_conditions]
      if @pass.save
        create_activity("created pass", @pass, "Pass", admin_pass_path(@pass),@pass.title, 'post')
        if !current_user.followers.blank?
          current_user.followers.each do |follower|
        if @notification = Notification.create!(recipient: follower, actor: current_user, action: User.get_full_name(current_user) + " created a new pass '#{@pass.title}'.", notifiable: @pass, url: "/admin/passes/#{@pass.id}", notification_type: 'mobile', action_type: 'create_pass') 
          @channel = "event" #encrypt later
          @current_push_token = @pubnub.add_channels_to_push(
           push_token: follower.device_token,
           type: 'gcm',
           add: follower.device_token
           ).value

           payload = { 
            "pn_gcm":{
             "notification":{
               "title": User.get_full_name(current_user),
               "body": @notification.action
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
           channel: follower.device_token,
           message: payload
           ) do |envelope|
               puts envelope.status
          end
         end # notificatiob end
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
      create_activity("deleted pass", @pass, "Pass", '', @pass.title, 'delete')
      redirect_to admin_passes_path, notice: "Pass deleted successfully."
    else
      flash[:alert_danger] = "Pass deletetion failed."
      redirect_to admin_passes_path
    end
  end


  private
   def pass_params
    params.permit(:title,:description, :validity,:user_id)
   end

   def generate_code
    code = SecureRandom.hex
   end

end
