class Admin::EventsController < Admin::AdminMasterController
  before_action :require_signin
  before_action :setCategories, only: ['new','edit','create']
  # using pubnub
  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

	def index
		@events = current_user.events.order(:created_at => 'DESC').page(params[:page])
	end

	def new
    @event = Event.new
    @event_attachment = @event.event_attachments.build
  end
  
  def edit
    @event = Event.find(params[:id]) 
  end

	def show
		@event = Event.find(params[:id]) or not_found
	end

  def create
    @pubnub = Pubnub.new(
      publish_key: ENV['PUBLISH_KEY'],
      subscribe_key: ENV['SUBSCRIBE_KEY']
     )
      if(params[:start_date] != params[:end_date])
         dates = (params[:start_date]..params[:end_date]).to_a
         dates.each do |date|
          @event = current_user.events.new
          @event.name = params[:name]
          @event.start_date = date
          @event.end_date = date
          @event.price = params[:price]
          @event.price_type = params[:price_type]
          @event.event_type = "mygo"
          @event.start_time = params[:start_time]
          @event.end_time = params[:end_time]
          @event.external_link = params[:external_link]
          @event.host = params[:host]
          @event.category_ids = params[:category_ids]
          @event.description = params[:description]
          @event.location = params[:location]
          @event.image = params[:image]
          @event.lat = params[:lat]
          @event.lng = params[:lng]
          @event.feature_media_link = params[:feature_media_link]
          @event.additional_media = params[:additional_media]
          @event.allow_chat = params[:allow_chat]
          @event.invitees = params[:invitees]
          @event.event_forwarding = params[:event_forwarding]
          @event.allow_additional_media = params[:allow_additional_media]
          @event.over_18 = params[:over_18]
          @event.save
          # create user activity log
          create_activity("created event", @event, "Event", admin_event_path(@event),@event.name, 'post')
          #create event setting
          EventSetting.create!(event_id: @event.id)
          if !params[:event_attachments].blank?
            params[:event_attachments]['media'].each do |m|
              @event_attachment = @event.event_attachments.new(:media => m,:event_id => @event.id, media_type: 'image')
              @event_attachment.save
             end
            end #if
          # notifiy all users about new event creation
        
           if !current_user.followers.blank?
            current_user.followers.each do |follower|
          if @notification = Notification.create!(recipient: follower, actor: current_user, action: User.get_full_name(current_user) + " created a new event '#{@event.name}'.", notifiable: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: 'create_event') 
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
        end #date end
        redirect_to admin_events_path
      else
      @event = current_user.events.new
      @event.name = params[:name]
      @event.start_date = params[:start_date].to_date.to_s
      @event.end_date = params[:end_date].to_date.to_s
      @event.price = params[:price]
      @event.price_type = params[:price_type]
      @event.event_type = "mygo"
      @event.start_time = params[:start_time]
      @event.end_time = params[:end_time]
      @event.external_link = params[:external_link]
      @event.host = params[:host]
      @event.category_ids = params[:category_ids]
      @event.description = params[:description]
      @event.location = params[:location]
      @event.image = params[:image]
      @event.lat = params[:lat]
      @event.lng = params[:lng]
      @event.feature_media_link = params[:feature_media_link]
      @event.additional_media = params[:additional_media]
      @event.allow_chat = params[:allow_chat]
      @event.invitees = params[:invitees]
      @event.event_forwarding = params[:event_forwarding]
      @event.allow_additional_media = params[:allow_additional_media]
      @event.over_18 = params[:over_18]
    if @event.save
      #creating activity log
      create_activity("created event", @event, "Event", admin_event_path(@event),@event.name, 'post')
      EventSetting.create!(event_id: @event.id)
      if !params[:event_attachments].blank?
      params[:event_attachments]['media'].each do |m|
        @event_attachment = @event.event_attachments.create!(:media => m,:event_id => @event.id, media_type: 'image')
       end
      end #if
      if !params[:event_attachments].blank?
        params[:event_attachments]['media'].each do |m|
          @event_attachment = @event.event_attachments.new(:media => m,:event_id => @event.id, media_type: 'image')
          @event_attachment.save
         end
        end #if
      # notifiy all users about new event creation
     
       if !current_user.followers.blank?
        current_user.followers.each do |follower|
      if @notification = Notification.create!(recipient: follower, actor: current_user, action: User.get_full_name(current_user) + " created a new event '#{@event.name}'.", notifiable: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: 'create_event') 
        @channel = "event" #encrypt later
        @current_push_token = @pubnub.add_channels_to_push(
         push_token: follower.device_token,
         type: 'gcm',
         add: @channel
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
         channel: @channel,
         message: payload
         ) do |envelope|
             puts envelope.status
        end
       end # notificatiob end
      end #each
      end # not blank
      flash[:notice] = "Event successfully created."
			redirect_to admin_events_path
		else
		    render :new
    end
  end # if dates are not equal
  end
  
  def update
    @event = Event.find(params[:id])
    if @event.update(event_params)
      create_activity("updated event", @event, "Event", admin_event_path(@event),@event.name, 'patch')
      flash[:notice] = "Event updated successfully."
      redirect_to admin_events_path
    else
      flash[:alert_danger] = "Event update failed, Please try again."
      redirect_to edit_admin_event_path(@event)
    end
  end

  def destroy
    @event = Event.find(params[:id])
    if @event.destroy
      create_activity("deleted event", @event, "Event",'',@event.name, 'delete')
      flash[:notice] = "Event deleted successfully."
      redirect_to admin_events_path
    else
      flash[:alert_danger] = "Event deletion failed."
      redirect_to admin_events_path
    end
  end

  private
  
  def setCategories
    @categories = Category.all
  end
	
  def event_params
		params.permit(:name,:start_date,:end_date,:price,:price_type,:event_type,:start_time, :end_time, :external_link, :host, :description,:location,:image, :feature_media_link, :additional_media, :lat,:lng,:allow_chat,:invitees,:event_forwarding,:allow_additional_media,:over_18, :category_ids => [], event_attachments_attributes: 
    [:id, :event_id, :media])
  end

end
