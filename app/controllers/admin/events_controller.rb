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
    
     
    @pubnub = Pubnub.new(
      publish_key: ENV['PUBLISH_KEY'],
      subscribe_key: ENV['SUBSCRIBE_KEY']
     ) 
       
      if(params[:start_date] != params[:end_date])
         dates = generate_date_range(params[:start_date], params[:end_date])
         dates.each do |date|
          @event = current_user.events.new
          @event.name = params[:name]
          @event.start_date = date.to_date
          @event.end_date = date.to_date
          @event.event_type = params[:event_type]
          @event.price_type = params[:price_type]
          @event.start_time = params[:start_time]
          @event.end_time = params[:end_time]
          @event.category_ids = params[:category_ids]
          @event.first_cat_id =  params[:category_ids].first
          @event.description = params[:description]
          @event.location = trim_space(params[:location])
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
              @ticket = @event.tickets.create!(user: current_user, ticket_type: 'free', quantity: params[:free_ticket]["quantity"], per_head: params[:free_ticket]["per_head"], price: 0)
              
           end #if
    
           if !params[:paid_ticket].blank?
         
            tickets = []      
            tota_count =  params[:paid_ticket][:price].size
            if tota_count > 1
             price_one =  params[:paid_ticket][:price].first.to_f
             price_two = params[:paid_ticket][:price].last.to_f
             start_price = ''
             end_price = ''
             if price_one < price_two
              start_price = price_one
              end_price = price_two
             else
              start_price = price_two
              end_price = price_one
             end
             @event.update!(start_price: start_price, end_price: end_price)
            else
              @event.update!(price: params[:paid_ticket][:price].first)
            end
            tota_count.times.each do |count|
             tickets << {
               "title" =>  params[:paid_ticket][:title][count-1],
               "price" => params[:paid_ticket][:price][count-1],
               "quantity" => params[:paid_ticket][:quantity][count-1],
               "per_head" => params[:paid_ticket][:per_head][count-1]
             }
            end #each
             tickets.each do |ticket|
              @ticket = @event.tickets.create!(user: current_user, title: ticket["title"], ticket_type: 'buy', quantity: ticket["quantity"], per_head: ticket["per_head"], price: ticket["price"])
             end #each
            end #if

            
           if !params[:pass].blank?
              passes = []      
              count = params[:passes_count]
              count.to_i.times.each do |count|
            passes << {
             "title" =>  params[:pass][:title][count-1],
             "description" =>  params[:pass][:description][count-1],
             "quantity" => params[:pass][:quantity][count-1],
             "ambassador_rate" => params[:pass][:ambassador_rate][count-1],
             "valid_from" => params[:pass][:valid_from][count-1],
             "valid_to" => params[:pass][:valid_to][count-1]
           }
          end #each
              passes.each do |pass|
              @pass = @event.passes.create!(user: current_user, title: pass["title"], quantity: pass["quantity"], valid_from: pass["valid_from"], valid_to: pass["valid_to"], validity: pass["valid_to"], ambassador_rate: pass["ambassador_rate"], description: pass["description"])
            end #each 
         end #if
    
        if !params[:pay_at_door].blank?
            @ticket = @event.tickets.create!(user: current_user, ticket_type: 'pay_at_door', start_price: params[:pay_at_door]["start_price"], end_price: params[:pay_at_door]["end_price"], price: 0)
            @event.update!(start_price: params[:pay_at_door]["start_price"], end_price:params[:pay_at_door]["end_price"])
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
      @event.price_type = params[:price_type]
      @event.start_time = params[:start_time]
      @event.end_time = params[:end_time]
      @event.host = params[:host]
      @event.category_ids = params[:category_ids]
      @event.first_cat_id =  params[:category_ids].first
      @event.description = params[:description]
      @event.location = trim_space(params[:location])
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
          @event_attachment = @event.event_attachments.new(:media => m,:event_id => @event.id, media_type: 'image')
          @event_attachment.save
         end
        end #if

        if !params[:sponsor_image].blank? && !params[:external_url].blank?
          @event_sponsor = @event.sponsors.create!(:name => params[:sponsor_name],:sponsor_image => params[:sponsor_image])
        end#if
      # notifiy all users about new event creation

      if !params[:free_ticket].blank?
          @ticket = @event.tickets.create!(user: current_user, ticket_type: 'free', quantity: params[:free_ticket]["quantity"], per_head: params[:free_ticket]["per_head"], price: 0)
          
       end #if

       if !params[:paid_ticket].blank?
         
        tickets = []      
        tota_count =  params[:paid_ticket][:price].size
        if tota_count > 1
         price_one =  params[:paid_ticket][:price].first.to_f
         price_two = params[:paid_ticket][:price].last.to_f
         start_price = ''
         end_price = ''
         if price_one < price_two
          start_price = price_one
          end_price = price_two
         else
          start_price = price_two
          end_price = price_one
         end
         @event.update!(start_price: start_price, end_price: end_price)
        else
          @event.update!(price: params[:paid_ticket][:price].first)
        end
        tota_count.times.each do |count|
         tickets << {
           "title" =>  params[:paid_ticket][:title][count-1],
           "price" => params[:paid_ticket][:price][count-1],
           "quantity" => params[:paid_ticket][:quantity][count-1],
           "per_head" => params[:paid_ticket][:per_head][count-1]
         }
        end #each
         tickets.each do |ticket|
          @ticket = @event.tickets.create!(user: current_user, title: ticket["title"], ticket_type: 'buy', quantity: ticket["quantity"], per_head: ticket["per_head"], price: ticket["price"])
         end #each
        end #if

        if !params[:pass].blank?
          passes = []      
          count = params[:passes_count]
          count.to_i.times.each do |count|
        passes << {
         "title" =>  params[:pass][:title][count-1],
         "description" =>  params[:pass][:description][count-1],
         "quantity" => params[:pass][:quantity][count-1],
         "ambassador_rate" => params[:pass][:ambassador_rate][count-1],
         "valid_from" => params[:pass][:valid_from][count-1],
         "valid_to" => params[:pass][:valid_to][count-1]
       }
      end #each
          passes.each do |pass|
          @pass = @event.passes.create!(user: current_user, title: pass["title"], quantity: pass["quantity"], valid_from: pass["valid_from"], valid_to: pass["valid_to"], validity: pass["valid_to"], ambassador_rate: pass["ambassador_rate"], description: pass["description"])
        end #each 
     end #if

    if !params[:pay_at_door].blank?
        @ticket = @event.tickets.create!(user: current_user, ticket_type: 'pay_at_door', start_price: params[:pay_at_door]["start_price"], end_price: params[:pay_at_door]["end_price"])
        @event.update!(start_price: params[:pay_at_door]["start_price"], end_price:params[:pay_at_door]["end_price"])
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
