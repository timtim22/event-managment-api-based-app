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
  @errors = []
  @event = current_user.events.new
  if params[:free_ticket].blank? && params[:paid_ticket].blank? && params[:pay_at_door].blank?
    flash[:alert_danger] = "One of the admission process must be defined."
    render :new
    return
   end

  @pubnub = Pubnub.new(
    publish_key: ENV['PUBLISH_KEY'],
    subscribe_key: ENV['SUBSCRIBE_KEY']
   )

   if params[:start_date] == params[:end_date]
        @event.name = params[:name]
        @event.start_date = params[:start_date].to_date
        @event.end_date = params[:end_date].to_date
        @event.event_type = params[:event_type]
        @event.price_type = params[:price_type]
        @event.start_time = params[:start_time]
        @event.end_time = params[:end_time]
        @event.host = params[:host]
        @event.category_ids = params[:category_ids]
        @event.first_cat_id =  params[:category_ids].first if params[:category_ids]
        @event.description = params[:description]
        @event.location = trim_space(params[:location])
        @event.image = params[:image]
        @event.video = params[:video]
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
            @event_attachment = @event.event_attachments.create!(:media => m,:event_id => @event.id, media_type: m.content_type.split('/').first)
          end
          end #if



         #in case of new sponsors
         if !params[:sponsors].blank?
          sponsors = []
          count = params[:sponsors]["images"].size
          count.to_i.times.each do |count|
           sponsors << {
           "image" =>  params[:sponsors]["images"][count-1],
           "external_url" =>  params[:sponsors]["external_urls"][count-1]
         }
       end #each
       if !sponsors.blank?
         sponsors.each do |sponsor|
           @event.sponsors.create!(sponsor_image: sponsor["image"], external_url: sponsor["external_url"])
         end#each
       end
     end #if


        # notifiy all users about new event creation

        if !params[:free_ticket].blank?
            @ticket = @event.tickets.create!(user: current_user, title: params[:free_ticket][:title], ticket_type: 'free', quantity: params[:free_ticket]["quantity"], per_head: params[:free_ticket]["per_head"], price: 0)

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
            count = params[:pass]['quantity'].size
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
          if @pass = @event.passes.create!(user: current_user, title: pass["title"], quantity: pass["quantity"], valid_from: pass["valid_from"], valid_to: pass["valid_to"], validity: pass["valid_to"], ambassador_rate: pass["ambassador_rate"], description: pass["description"], redeem_code: generate_code)

            @event.update!(pass: 'true')
          end
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
        if @notification = Notification.create!(recipient: follower, actor: current_user, action: get_full_name(current_user) + " created a new event '#{@event.name}'.", notifiable: @event, resource: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: 'create_event')
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
   else###############################
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
      @event.first_cat_id =  params[:category_ids].first if params[:category_ids]
      @event.description = params[:description]
      @event.location = trim_space(params[:location])
      @event.image = params[:image]
      @event.lat = params[:lat]
      @event.lng = params[:lng]
      @event.terms_conditions = params[:terms_conditions]
      @event.allow_chat = params[:allow_chat]
      @event.event_forwarding = params[:event_forwarding]
      @event.allow_additional_media = params[:allow_additional_media]
     if @event.save

      if !params[:event_attachments].blank?

        params[:event_attachments]['media'].each do |m|
          @event_attachment = @event.event_attachments.create!(:media => m,:event_id => @event.id, media_type: m.content_type.split('/').first)
        end
        end #if


         #in case of new sponsors
         if !params[:sponsors].blank?
          sponsors = []
          count = params[:sponsors]["images"].size
          count.to_i.times.each do |count|
           sponsors << {
           "image" =>  params[:sponsors]["images"][count-1],
           "external_url" =>  params[:sponsors]["external_urls"][count-1]
         }
       end #each
       if !sponsors.blank?
         sponsors.each do |sponsor|
           @event.sponsors.create!(sponsor_image: sponsor["image"], external_url: sponsor["external_url"])
         end#each
       end
     end #if


      # notifiy all users about new event creation

      if !params[:free_ticket].blank?
          @ticket = @event.tickets.create!(user: current_user, title: params[:free_ticket][:title], ticket_type: 'free', quantity: params[:free_ticket]["quantity"], per_head: params[:free_ticket]["per_head"], price: 0)

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
          count = params[:pass]['quantity'].size
          count.to_i.times.each do |count|
        passes << {
         "title" =>  params[:pass][:title][count-1],
         "description" =>  params[:pass][:description][count-1],
         "terms_conditions" =>  params[:pass][:terms_conditions][count-1],
         "quantity" => params[:pass][:quantity][count-1],
         "ambassador_rate" => params[:pass][:ambassador_rate][count-1],
         "valid_from" => params[:pass][:valid_from][count-1],
         "valid_to" => params[:pass][:valid_to][count-1]
       }
      end #each
        passes.each do |pass|
         if @pass = @event.passes.create!(user: current_user, title: pass["title"], quantity: pass["quantity"], valid_from: pass["valid_from"], valid_to: pass["valid_to"], validity: pass["valid_to"], ambassador_rate: pass["ambassador_rate"], description: pass["description"],terms_conditions: pass["terms_conditions"], redeem_code: generate_code)

          @event.update!(pass: 'true')
         end
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


     else
       @errors.push(@event.errors.full_messages)
     end
    end #date each
      if @errors.blank?
        flash[:notice] = "Event successfully created."
        redirect_to admin_events_path
      else
       render :new
      end
   end #main else end
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

       # in case of new attachments
      if !params[:attachments].blank?
        params[:attachments]['media'].each do |m|
          @event_attachment = @event.event_attachments.create!(:media => m,:event_id => @event.id, media_type: 'image')
         end #each
        end #if

      #in case of update attachments
      if !params[:update_attachments].blank?
         ids = params[:attachments][:ids]

         ids.each do |id|
          if !params[:update_attachments]["#{id}"].blank?
          @event.event_attachments.find(id).update(:media => params[:update_attachments]["#{id}"]["media"][0], media_type: 'image')
          end
         end #each
        end #if




         #in case of updsate sponsors
        if !params[:update_sponsors].blank?
          ids = params[:update_sponsors][:ids]
          ids.each do |id|
          if !params[:update_sponsors]["#{id}"][:images].blank?
            @event.sponsors.find(id).update!(sponsor_image: params[:update_sponsors]["#{id}"][:images][0], external_url: params[:update_sponsors]["#{id}"][:external_urls][0])
            elsif !params[:update_sponsors]["#{id}"][:external_urls].blank?
              @event.sponsors.find(id).update!(external_url: params[:update_sponsors]["#{id}"][:external_urls][0])
            end
       end #each
      end#if



        #in case of new sponsors
        if !params[:sponsors].blank?
           sponsors = []
           count = params[:sponsors]["images"].size
           count.to_i.times.each do |count|
            sponsors << {
            "image" =>  params[:sponsors]["images"][count-1],
            "external_url" =>  params[:sponsors]["external_urls"][count-1]
          }
        end #each
        if !sponsors.blank?
          sponsors.each do |sponsor|
            @event.sponsors.create!(sponsor_image: sponsor["image"], external_url: sponsor["external_url"])
          end#each
        end
      end #if

    #     sponsors.each do |sponsor|
    #         @event_sponsor = @event.sponsors.create!(:sponsor_image => sponsor["image"], :external_url => sponsor["external_url"])
    #     end #each
    #     end#if


      # notifiy all users about new event creation

      if !params[:free_ticket].blank?
         if !params[:free_ticket][:id].nil?
        @ticket = @event.tickets.find(params[:free_ticket][:id]).update!(user: current_user, title: params[:free_ticket][:title], ticket_type: 'free', quantity: params[:free_ticket]["quantity"], per_head: params[:free_ticket]["per_head"], price: 0)
         else
          @ticket = @event.tickets.create!(user: current_user, title: params[:free_ticket][:title], ticket_type: 'free', quantity: params[:free_ticket]["quantity"], per_head: params[:free_ticket]["per_head"], price: 0)
         end
       end #if



       #if paid tickets already existed
       if !params[:update_paid_ticket].blank?
        tickets = []
        tota_count =  params[:update_paid_ticket][:price].size
        if tota_count > 1
         price_one =  params[:update_paid_ticket][:price].first.to_f
         price_two = params[:update_paid_ticket][:price].last.to_f
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
           "id" => params[:update_paid_ticket]["ids"][count-1],
           "title" =>  params[:update_paid_ticket][:title][count-1],
           "price" => params[:update_paid_ticket][:price][count-1],
           "quantity" => params[:update_paid_ticket][:quantity][count-1],
           "per_head" => params[:update_paid_ticket][:per_head][count-1]
         }
        end #each

         tickets.each do |ticket|
          @ticket = @event.tickets.find(ticket["id"]).update!(user: current_user, title: ticket["title"], ticket_type: 'buy', quantity: ticket["quantity"], per_head: ticket["per_head"], price: ticket["price"])
         end #each
        end #if


        #new paid ticket
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



         #if pass is already existed.
        if !params[:update_pass].blank?
          passes = []
          count = params[:update_pass]['quantity'].size
          count.to_i.times.each do |count|
            passes << {
            "id" => params[:update_pass]["ids"][count-1],
            "title" =>  params[:update_pass][:title][count-1],
            "description" =>  params[:update_pass][:description][count-1],
            "terms_conditions" =>  params[:update_pass][:terms_conditions][count-1],
            "quantity" => params[:update_pass][:quantity][count-1],
            "ambassador_rate" => params[:update_pass][:ambassador_rate][count-1],
            "valid_from" => params[:update_pass][:valid_from][count-1],
            "valid_to" => params[:update_pass][:valid_to][count-1]
          }
      end #each

      passes.each do |pass|
        @pass = @event.passes.find(pass["id"]).update!(user: current_user, title: pass["title"], quantity: pass["quantity"], valid_from: pass["valid_from"], valid_to: pass["valid_to"], validity: pass["valid_to"], ambassador_rate: pass["ambassador_rate"], description: pass["description"], terms_conditions: pass["terms_conditions"], redeem_code: generate_code)
      end #each
   end #if


      #if pass ins new
      if !params[:pass].blank?
        passes = []
        count = params[:pass]['quantity'].size
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
        @pass = @event.passes.create!(user: current_user, title: pass["title"], quantity: pass["quantity"], valid_from: pass["valid_from"], valid_to: pass["valid_to"], validity: pass["valid_to"], ambassador_rate: pass["ambassador_rate"], description: pass["description"], redeem_code: generate_code)
        @event.update!(pass: 'true')
      end #each
   end #if



    if !params[:pay_at_door].blank?
      if !params[:pay_at_door]["id"].nil?
        @ticket = @event.tickets.find(params[:pay_at_door][:id]).update!(user: current_user, ticket_type: 'pay_at_door', start_price: params[:pay_at_door]["start_price"], end_price: params[:pay_at_door]["end_price"])
        @event.update!(start_price: params[:pay_at_door]["start_price"], end_price:params[:pay_at_door]["end_price"])
      else
        @ticket = @event.tickets.create!(user: current_user, ticket_type: 'pay_at_door', start_price: params[:pay_at_door]["start_price"], end_price: params[:pay_at_door]["end_price"])
        @event.update!(start_price: params[:pay_at_door]["start_price"], end_price:params[:pay_at_door]["end_price"])
      end
     end #if




      flash[:notice] = "Event updated successfully."
      redirect_to admin_events_path
    else
      flash[:alert_danger] = @event.errors.full_messages
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


  def delete_resource
    id = params[:id]
    resource = params[:resource]
    success = false
    case resource
    when 'ticket'
     if Ticket.find(id).destroy
      success = true
     end
    when 'pass'
     if Pass.find(id).destroy
      success = true
     end
    else
      "do nothing"
    end
    if success
    render json: {
      code: 200,
      success: true,
      message: 'Resource successfully deleted.',
      data: nil
    }
  else
      render json: {
        code: 400,
        success: false,
        message: 'Resource deletion failed.',
        data: nil
      }
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
