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
    location = {
      "short_address": params[:location],
      "full_address": "",
      "geometry": {
        "lat": params[:lat],
        "lng": params[:lng]
      }
    }
      @competition = current_user.own_competitions.new
      @competition.title = params[:title]
      @competition.description = params[:description]
      @competition.start_date = params[:start_date]
      @competition.end_date = params[:end_date]
      @competition.price = params[:price]
      @competition.start_time = params[:start_time]
      @competition.end_time = params[:end_time]
      @competition.image = params[:image]
      @competition.validity = params[:validity]
      @competition.host = params[:host]
      @competition.validity_time = params[:end_time]
      @competition.terms_conditions = params[:terms_conditions]
      @competition.location = location
      
    if @competition.save
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
      #create_activity("created competition", @competition, "Competition", admin_competition_path(@competition),@competition.title, 'post')
      if !current_user.followers.blank?
        current_user.followers.each do |follower|
   if follower.competitions_notifications_setting.is_on == true
      if notification = Notification.create!(recipient: follower, actor: current_user, action: get_full_name(current_user) + " created a new competition '#{@competition.title}'.", notifiable: @competition, resource: @competition, url: "/admin/competitions/#{@competition.id}", notification_type: 'mobile', action_type: 'create_competition')

        @current_push_token = @pubnub.add_channels_to_push(
         push_token: follower.device_token,
         type: 'gcm',
         add: follower.device_token
         ).value

         payload = {
          "pn_gcm":{
           "notification":{
             "title": get_full_name(current_user),
             "body": notification.action
           },
           data: {
            "id": notification.id,
            "competition_id": notification.resource.id,
            "actor_id": notification.actor_id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "location": location,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "competition_name": notification.resource.title,
            "business_name": User.get_full_name(notification.resource.user),
            "draw_date": notification.resource.validity.strftime(get_time_format),
            "is_added_to_wallet": added_to_wallet?(request_user, notification.resource)
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
      location = {
        "short_address": params[:location],
        "full_address": "",
        "geometry": {
          "lat": params[:lat],
          "lng": params[:lng]
        }
      }
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
        @competition.validity_time = params[:end_time]
        @competition.terms_conditions = params[:terms_conditions]
        @competition.location = location
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
		params.permit(:title,:user_id,:description,:start_date,:end_date,:price, :terms_conditions, :start_time, :end_time,:image,:validity,:validity_time,:lat,:lng,:location,:host)
  end


end
