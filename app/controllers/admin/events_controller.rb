class Admin::EventsController < Admin::AdminMasterController
  before_action :require_signin
  before_action :setCategories, only: ['new','edit','create']
  # using pubnub
  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
 

	def index
		@events = current_user.events.sort_by_date.page(params[:page])
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

    fail
 
    @pubnub = Pubnub.new(
      publish_key: ENV['PUBLISH_KEY'],
      subscribe_key: ENV['SUBSCRIBE_KEY']
     ) 
      
       
      if(params[:start_date] != params[:end_date])
         dates = (params[:start_date]..params[:end_date]).to_a
         dates.each do |date|
          @event = current_user.events.new
          @event.name = params[:name]
          @event.start_date = date.to_date
          @event.end_date = date.to_date
          @event.event_type = params[:event_type]
          @event.start_time = params[:start_time]
          @event.end_time = params[:end_time]
          @event.category_ids = params[:category_ids]
          @event.description = params[:description]
          @event.location = params[:location]
          @event.image = params[:image]
          @event.lat = params[:lat]
          @event.lng = params[:lng]
          @event.terms_conditions = params[:terms_conditions]
          @event.allow_chat = params[:allow_chat]
          @event.event_forwarding = params[:event_forwarding]
          @event.allow_additional_media = params[:allow_additional_media]
          @event.save
          # create user activity log
          #create_activity("created event", @event, "Event", admin_event_path(@event),@event.name, 'post')
         
          if !params[:event_attachments].blank?
            params[:event_attachments]['media'].each do |m|
              @event_attachment = @event.event_attachments.new(:media => m,:event_id => @event.id, media_type: 'image')
              @event_attachment.save
             end
            end #if

            if !params[:sponsor_image].blank? && !params[:external_url].blank?
              @event_sponsor = @event.sponsors.create!(:name => params[:sponsor_name],:sponsor_image => params[:sponsor_image])
            end#if
          # notifiy all users about new event creation

          if !params[:free_ticket].blank?
              @ticket = @event.tickets.create!(ticket_type: 'free', quantity: params[:free_ticket][:quantity], per_head: params[:free_ticket][:per_head])
          
           end #if

           if !params[:paid_ticket].blank?
            params[:paid_ticket]['title'].each do |t|
              params[:paid_ticket]['quantity'].each do |q|
                params[:paid_ticket]['price'].each do |p|
                  params[:paid_ticket]['per_head'].each do |per|
                @ticket = @event.tickets.create!(ticket_type: 'paid', quantity: q, per_head: per, price: p)
             end
            end
            end
          end
            end #if


            if !params[:pass].blank?
              params[:pass]['title'].each do |t|
                params[:pass]['quantity'].each do |q|
                  params[:pass]['ambassador_rate'].each do |rate|
                    params[:pass]['per_head'].each do |per|
                      params[:pass]['valid_from'].each do |from|
                        params[:pass]['valid_to'].each do |to|
                         @ticket = @event.passes.create!(title: t,, quantity: q, per_head: per, price: p)
               end
              end
              end
            end
              end #if

        if !params[:pay_at_door].blank?
            @ticket = @event.tickets.create!(ticket_type: 'pay_at_door', pay_at_door)
         end #if


        
       if !current_user.followers.blank?
            current_user.followers.each do |follower|
        if follower.all_chat_notifications_setting.is_on == true && follower.event_notifications_setting.is_on == true
          if @notification = Notification.create!(recipient: follower, actor: current_user, action: get_full_name(current_user) + " created a new event '#{@event.name}'.", notifiable: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: 'create_event') 
            @channel = "event" #encrypt later
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
                "body": '' 
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
          end #all chat and event chat true
          end #each
          end # not blank
        end #date end
        redirect_to admin_events_path
      else
      @event = current_user.events.new
      @event.name = params[:name]
      @event.start_date = params[:start_date].to_date
      @event.end_date = params[:end_date].to_date
      @event.event_type = params[:event_type]
      @event.start_time = params[:start_time]
      @event.end_time = params[:end_time]
      @event.host = params[:host]
      @event.category_ids = params[:category_ids]
      @event.description = params[:description]
      @event.location = params[:location]
      @event.image = params[:image]
      @event.lat = params[:lat]
      @event.lng = params[:lng]
      @event.feature_media_link = params[:feature_media_link]
      @event.terms_conditions = params[:terms_conditions]
      @event.allow_chat = params[:allow_chat]
      @event.invitees = params[:invitees]
      @event.event_forwarding = params[:event_forwarding]
      @event.allow_additional_media = params[:allow_additional_media]
      @event.over_18 = params[:over_18]
    if @event.save
      #creating activity log
      #create_activity("created event", @event, "Event", admin_event_path(@event),@event.name, 'post')

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
      if follower.all_chat_notifications_setting.is_on == true && follower.event_notifications_setting.is_on == true
      if @notification = Notification.create!(recipient: follower, actor: current_user, action: get_full_name(current_user) + " created a new event '#{@event.name}'.", notifiable: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: 'create_event') 
        @channel = "event" #encrypt later
        @current_push_token = @pubnub.add_channels_to_push(
         push_token: follower.profile.device_token,
         type: 'gcm',
         add: @channel
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
         channel: @channel,
         message: payload
         ) do |envelope|
             puts envelope.status
        end
       end # notificatiob end
      end #all chat and event chat true
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
    if params[:price_type == 'free']
      price_range = false
      price = 0.00
      start_price = 0.00
      end_price = 0.00
   else
    if params[:price_range] == 'on'
      price_range = true
      price = params[:start_price]
      start_price = params[:start_price]
      end_price = params[:end_price]
    else
      price_range = false
      price = params[:price]
      start_price = 0.00
      end_price = 0.00
    end
   end  

    @event = Event.find(params[:id])
    @event.name = params[:name]
    @event.start_date = params[:start_date].to_date.to_s
    @event.end_date = params[:end_date].to_date.to_s
    @event.price_range = price_range
    @event.price = price
    @event.start_price = start_price
    @event.end_price = end_price
    @event.price_type = params[:price_type]
    @event.event_type = params[:event_type]
    @event.start_time = params[:start_time]
    @event.end_time = params[:end_time]
    @event.host = params[:host]
    @event.category_ids = params[:category_ids]
    @event.description = params[:description]
    @event.location = params[:location]
    @event.image = params[:image]
    @event.lat = params[:lat]
    @event.lng = params[:lng]
    @event.feature_media_link = params[:feature_media_link]
    @event.terms_conditions = params[:terms_conditions]
    @event.allow_chat = params[:allow_chat]
    @event.invitees = params[:invitees]
    @event.event_forwarding = params[:event_forwarding]
    @event.allow_additional_media = params[:allow_additional_media]
    @event.over_18 = params[:over_18]
  if @event.save
      #create_activity("updated event", @event, "Event", admin_event_path(@event),@event.name, 'patch')
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
     # create_activity("deleted event", @event, "Event",'',@event.name, 'delete')
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
		params.permit(:name,:start_date,:end_date,:price,:price_type,:event_type,:start_time, :end_time, :host, :description,:location,:image, :feature_media_link, :lat,:lng,:allow_chat,:invitees,:event_forwarding,:allow_additional_media,:over_18, :category_ids => [], event_attachments_attributes: 
    [:id, :event_id, :media])
  end

end
