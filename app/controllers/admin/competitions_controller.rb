class Admin::CompetitionsController < Admin::AdminMasterController
  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  
  def index
    @competitions = current_user.own_competitions.order(created_at: "DESC")
  end

  def show
    @competition = Competition.find(params[:id])
  end

  def new
    @competition = Competition.new
  end
  
  def create
      @competition = current_user.own_competitions.new   
      @competition.title = params[:title]
      @competition.description = params[:description]
      @competition.start_date = params[:start_date]
      @competition.end_date = params[:end_date]
      @competition.price = params[:price]
      @competition.start_time = params[:start_time]
      @competition.end_time = params[:end_time]
      @competition.image = params[:image]
      @competition.validity = string_to_DateTime(params[:validity])
      @competition.host = params[:host]
      @competition.validity_time = params[:end_time]
      @competition.location = params[:location]
      @competition.lat = params[:lat]
      @competition.lng = params[:lng]
    if @competition.save
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
      #create_activity("created competition", @competition, "Competition", admin_competition_path(@competition),@competition.title, 'post')
      if !current_user.followers.blank?
        current_user.followers.each do |follower|
   if follower.competitions_notifications_setting.is_on == true
      if @notification = Notification.create!(recipient: follower, actor: current_user, action: get_full_name(current_user) + " created a new competition '#{@competition.title}'.", notifiable: @competition, url: "/admin/competitions/#{@competition.id}", notification_type: 'mobile', action_type: 'create_competition') 
  
        @current_push_token = @pubnub.add_channels_to_push(
         push_token: follower.device_token,
         type: 'gcm',
         add: follower.device_token
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
       end # notification end
      end #competition setting
      end #each
      end # not blank
      redirect_to admin_competitions_path, notice: "Competition created successfully."
    else
      render :new
    end
  end

  def edit
    @competition = Competition.find(params[:id])
  end

  def update
        @competition = Competition.find(params[:id])
        @competition.title = params[:title]
        @competition.description = params[:description]
        @competition.start_date = params[:start_date]
        @competition.end_date = params[:end_date]
        @competition.price = params[:price]
        @competition.start_time = params[:start_time]
        @competition.end_time = params[:end_time]
        @competition.image = params[:image]
        @competition.validity = string_to_DateTime(params[:validity])
        @competition.host = params[:host]
        @competition.validity_time = params[:validity_time]
        @competition.location = params[:location]
        @competition.lat = params[:lat]
        @competition.lng = params[:lng]
    if @competition.save
      #create_activity("updated competition", @competition, "Competition", admin_competition_path(@competition),@competition.title, 'patch')
      redirect_to admin_competitions_path, notice: "Competition updated successfully."
    else
      flash[:alert_danger] = "Competition update failed."
      redirect_to admin_competitions_path
    end 
  end

  def destroy
    @competition = Competition.find(params[:id])
    if @competition.destroy
       redirect_to admin_competitions_path, notice: "Competition deleted successfully."
    else
      flash[:alert_danger] = "Competition deletion failed."
      redirect_to admin_competitions_path
    end
  end

  private
  def competition_params
		params.permit(:title,:user_id,:description,:start_date,:end_date,:price,:start_time, :end_time,:image,:validity,:validity_time,:lat,:lng,:location,:host)
  end


end
