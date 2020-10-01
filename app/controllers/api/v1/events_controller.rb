class Api::V1::EventsController < Api::V1::ApiMasterController
  before_action :authorize_request, except:  ['events_list_by_date','index']

  def initialize
    
  end

  # def index
  #   @events = []
  #   @empty = {}
  #   events = Event.sort_by_date.page(params[:page]).per(20).eager_load(:passes, :tickets, :event_attachments, :categories, :interest_levels, :sponsors)
  #   events.map  { |e|
  #     @passes = []
  #     @ticket = []
  #     if request_user
  #     e.passes.not_expired.map { |pass|
  #       if !is_removed_pass?(request_user, pass)
  #       @passes << {
  #       id: pass.id,
  #       title: pass.title,
  #       host_name: e.user.business_profile.profile_name,
  #       host_image: e.user.avatar,
  #       event_name: e.name,
  #       event_image: e.image,
  #       event_location: e.location,
  #       event_start_time: e.start_time,
  #       event_end_time: e.end_time,
  #       event_date: e.start_date,
  #       is_added_to_wallet: is_added_to_wallet?(pass.id),
  #       validity: pass.validity.strftime(get_time_format),
  #       grabbers_count: pass.wallets.size,
  #       terms_and_conditions: pass.terms_conditions,
  #       description: pass.description,
  #       issued_by: get_full_name(pass.user),
  #       redeem_count: get_redeem_count(pass),
  #       quantity: pass.quantity
  #     }
  #   end# remove if
  # } #map
  # else 
  #   e.passes.not_expired.map { |pass|
  #     @passes << {
  #     id: pass.id,
  #     title: pass.title,
  #     description: pass.description,
  #     host_name: e.user.business_profile.profile_name,
  #     host_image: e.user.avatar,
  #     event_name: e.name,
  #     event_image: e.image,
  #     event_location: e.location,
  #     event_start_time: e.start_time,
  #     event_end_time: e.end_time,
  #     event_date: e.start_date,
  #     is_added_to_wallet: is_added_to_wallet?(pass.id),
  #     validity: pass.validity.strftime(get_time_format),
  #     grabbers_count: pass.wallets.size,
  #     terms_and_conditions: pass.terms_conditions,
  #     description: pass.description,
  #     issued_by: get_full_name(pass.user),
  #     redeem_count: get_redeem_count(pass),
  #     quantity: pass.quantity
  #   }
  # }# passes map
  # end #if request_user

  #   if e.ticket
  #     @ticket << {
  #     "id" => e.ticket.id,
  #     'title' => e.ticket.title,
  #     'event_name' => e.name,
  #     'price' => e.ticket.price,
  #     "quantity" => e.ticket.quantity,
  #     'ticket_type' => e.ticket.ticket_type,
  #     'per_head' => e.ticket.per_head,
  #     'is_purchased' => is_ticket_purchased(e.ticket.id)
  #     }
  #   end #if

  #     @events << {
  #       'id' => e.id,
  #       'name' => e.name,
  #       'description' => e.description,
  #       'start_date' => e.start_date,
  #       'end_date' => e.end_date,
  #       'start_time' => e.start_time,
  #       'end_time' => e.end_time,
  #       'price' => e.price, # check for price if it is zero
  #       'price_type' => e.price_type,
  #       'event_type' => e.event_type,
  #       'additional_media' => e.event_attachments,
  #       'location' => e.location,
  #       'lat' => e.lat,
  #       'lng' => e.lng,
  #       'image' => e.image,
  #       'is_interested' => is_interested?(e),
  #       'is_going' => is_attending?(e),
  #       'is_followed' => is_followed(e.user),
  #       'interest_count' => e.interested_interest_levels.size,
  #       'going_count' => e.going_interest_levels.size,
  #       'followers_count' => e.user ? e.user.followers.size : nil ,
  #       'following_count' => e.user ? e.user.followings.size : nil,
  #       'demographics' => get_demographics(e),
  #       'passes' =>  @passes,
  #       'ticket' => @ticket,
  #       'passes_grabbers_friends_count' =>  get_passes_grabbers_friends_count(e),
  #       'going_users' => e.going_users,
  #       "interested_users" => getInterestedUsers(e),
  #       'creator_name' => e.user.business_profile.profile_name,
  #       'creator_id' => e.user.id,
  #       'creator_image' => e.user.avatar,
  #       'categories' => !e.categories.blank? ? e.categories : @empty,
  #       'grabbers' => get_event_passes_grabbers(e),
  #       'sponsors' => e.sponsors,
  #       "mute_chat" => get_mute_chat_status(e),
  #       "mute_notifications" => get_mute_notifications_status(e),
  #       "terms_and_conditions" => e.terms_conditions 
  #    }
     
  #   } #map



	# 	render json: {
  #     code: 200,
  #     success: true,
  #     message: '',
	# 		data: { 
  #      "events" => @events
  #    }
  # }
 
  # end

  def show_event
    if !params[:event_id].blank?
      e = Event.find(params[:event_id])
      @passes = []
          @ticket = []
          if request_user
          e.passes.not_expired.map { |pass|
            if !is_removed_pass?(request_user, pass)
            @passes << {
            id: pass.id,
            title: pass.title,
            host_name: e.user.business_profile.profile_name,
            host_image: e.user.avatar,
            event_name: e.name,
            event_image: e.image,
            event_location: e.location,
            event_start_time: e.start_time,
            event_end_time: e.end_time,
            event_date: e.start_date,
            is_added_to_wallet: is_added_to_wallet?(pass.id),
            validity: pass.validity.strftime(get_time_format),
            grabbers_count: pass.wallets.size,
            terms_and_conditions: pass.terms_conditions,
            description: pass.description,
            issued_by: get_full_name(pass.user),
            redeem_count: get_redeem_count(pass),
            quantity: pass.quantity
          }
        end# remove if
      } #map
      else 
        e.passes.not_expired.map { |pass|
          @passes << {
          id: pass.id,
          title: pass.title,
          description: pass.description,
          host_name: e.user.business_profile.profile_name,
          host_image: e.user.avatar,
          event_name: e.name,
          event_image: e.image,
          event_location: e.location,
          event_start_time: e.start_time,
          event_end_time: e.end_time,
          event_date: e.start_date,
          is_added_to_wallet: is_added_to_wallet?(pass.id),
          validity: pass.validity.strftime(get_time_format),
          grabbers_count: pass.wallets.size,
          terms_and_conditions: pass.terms_conditions,
          description: pass.description,
          issued_by: get_full_name(pass.user),
          redeem_count: get_redeem_count(pass),
          quantity: pass.quantity
        }
      }# passes map
      end #if request_user
    
        if e.ticket
          @ticket << {
          "id" => e.ticket.id,
          'title' => e.ticket.title,
          'event_name' => e.name,
          'price' => e.ticket.price,
          "quantity" => e.ticket.quantity,
          'ticket_type' => e.ticket.ticket_type,
          'per_head' => e.ticket.per_head,
          'is_purchased' => is_ticket_purchased(e.ticket.id)
          }
        end #if
    
          @event = {
            'id' => e.id,
            'name' => e.name,
            'description' => e.description,
            'start_date' => e.start_date,
            'end_date' => e.end_date,
            'start_time' => e.start_time,
            'end_time' => e.end_time,
            'price' => e.price, # check for price if it is zero
            'price_type' => e.price_type,
            'event_type' => e.event_type,
            'additional_media' => e.event_attachments,
            'location' => e.location,
            'lat' => e.lat,
            'lng' => e.lng,
            'image' => e.image,
            'is_interested' => is_interested?(e),
            'is_going' => is_attending?(e),
            'is_followed' => is_followed(e.user),
            'interest_count' => e.interested_interest_levels.size,
            'going_count' => e.going_interest_levels.size,
            'followers_count' => e.user ? e.user.followers.size : nil ,
            'following_count' => e.user ? e.user.followings.size : nil,
            'demographics' => get_demographics(e),
            'passes' =>  @passes,
            'ticket' => @ticket,
            'passes_grabbers_friends_count' =>  get_passes_grabbers_friends_count(e),
            'going_users' => e.going_users,
            "interested_users" => getInterestedUsers(e),
            'creator_name' => e.user.business_profile.profile_name,
            'creator_id' => e.user.id,
            'creator_image' => e.user.avatar,
            'categories' => !e.categories.blank? ? e.categories : @empty,
            'grabbers' => get_event_passes_grabbers(e),
            'sponsors' => e.sponsors,
            "mute_chat" => get_mute_chat_status(e),
            "mute_notifications" => get_mute_notifications_status(e),
            "terms_and_conditions" => e.terms_conditions 
         }

         render json: {
           code: 200,
           success: true,
           message: '',
           data: {
             event: @event
           }
         }

    else
      render json: {
        code: 400,
        success: false,
        message: "event_id is required.",
        data: nil
      }
    end
  end
  
  def index
    @events = Event.sort_by_date.page(params[:page]).per(30).eager_load(:passes, :tickets)
    @response = @events.map {|event|
     e = {
      "id" => event.id,
      "image" => event.image,
      "name" => event.name,
      "location" => event.location,
      "start_date" => event.end_date,
      "end_date" => event.end_date,
      "start_time" => event.start_time,
      "end_time" => event.end_time,
      "price_type" => get_price_type(event),
      "price" => get_price(event).to_s + "€",
      "price" => event.price,
      "has_pass" => has_pass?(event),
      "created_at" => event.created_at
    }
  }
    
    render json: {
        code: 200,
        success: true,
        message: '',
        data: { 
          "events" => @response
        }
      }
  end

	def events_list_by_date
		@events = Event.events_by_date(params[:date])
		render json: @events
	end

	def show
		@event = Event.find(params[:event_id])
		render json: {
			status: true,
			event: @event
		}
	end

	def new
		@event = Event.new
	end

  def create
    @event = Event.new(event_params)
    # Notify all mygo user about event creation
    @pubnub = Pubnub.new(
      publish_key: ENV['PUBLISH_KEY'],
      subscribe_key: ENV['SUBSCRIBE_KEY']
    )
    (User.all - [request_user]).each do |user|
      if @notification = Notification.create(recipient: user, actor: request_user, action: get_full_name(request_user) + " posted a new event.", notifiable: @event, url: '/admin/events', notification_type: 'web')  
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: user.profile.device_token,
          type: 'gcm',
          add: user.profile.device_token
          ).value

        payload = { 
        "pn_gcm":{
          "notification":{
            "title": @notification.action,
          },
          "type": @notification.notifiable_type,
          "event_id": @event.id 
        }
      }

        @pubnub.publish(
         channel: [user.profile.device_token],
         message: payload
          ) do |envelope|
            puts envelope.status
        end
      end ##notification create
    end #each
		if @event.save
			render json: {
				status: true,
				message: "Event successfully created."
			}
			
		else
		    render json: {
		    	status: false,
		    	message: @event.errors.full_messages
		    }
		end
  end
  
  def report_event
   if !params[:event_id].blank? && !params[:reason].blank?
    if request_user.reported_events.create!(event_id: params[:event_id], reason: params[:reason])
    render json: {
      code: 200,
      success: true,
      message: 'Event successfully reported.',
      data: nil
    }
  else
    render json: {
      code: 400,
      success: false,
      message: "Event couldn't be reported."
    }
  end   
   else
    render json: {
      code: 400,
      success: false,
      message: 'event_id and reason are required fields.',
      data: nil
    }
   end

  end

  def create_view
    if !params[:event_id].blank?
      event = Event.find(params[:event_id])
    if view = event.views.create!(user_id: request_user.id)
      render json: {
        code: 200,
        success: true,
        message: "Event view successfully created.",
        data: nil
      }
      else
        render json: {
        code: 400,
        success: false,
        message: event.errors.full_messages,
        data: nil
      }
    end
    else
      render json: {
        code: 400,
        success: false,
        message: "event_id is requried field.",
        data: nil
      }
    end
  end


  private 

  # calculates interest level demographics interested + going
 
	def event_params
		params.permit(:name,:date,:start_time, :end_time, :external_link, :host, :description,:location,:image, :feature_media_link, :additinal_media, :allow_chat,:invitees,:event_forwarding,:allow_additional_media,:over_18)
  end
end
