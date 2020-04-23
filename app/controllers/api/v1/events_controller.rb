class Api::V1::EventsController < Api::V1::ApiMasterController
  before_action :authorize_request, except:  ['events_list_by_date']

  def initialize
    
  end

  def index
    @events = []
    @empty = {}
    events = Event.all
    events.each do |e|
      @passes = []
      @ticket = []
      e.passes.each do |pass|
      @passes << {
        id: pass.id,
        title: pass.title,
        host_name: e.user.first_name + " " + e.user.last_name,
        host_image: e.user.avatar.url,
        event_name: e.name,
        event_image: e.image,
        event_location: e.location,
        event_start_time: e.start_time,
        event_end_time: e.end_time,
        event_date: e.start_date,
        ambassador_name: pass.ambassador_name,
        is_added_to_wallet: is_added_to_wallet?(pass.id),
        validity: pass.validity + " " + pass.validity_time.strftime("%H:%M:%S").to_s,
        grabbers_count: pass.wallets.size
      }
    end

    if e.ticket
      @ticket << {
      "id" => e.ticket.id,
      'title' => e.ticket.title,
      'event_name' => e.name,
      'price' => e.ticket.price,
      "quantity" => e.ticket.quantity,
      'ticket_type' => e.ticket.ticket_type,
      'quantity' => e.ticket.quantity,
      'per_head' => e.ticket.per_head,
      'is_purchased' => is_ticket_purchased(e.ticket.id)
      }
    end #if

      @events << {
        'id' => e.id,
        'name' => e.name,
        'description' => e.description,
        'start_date' => e.start_date,
        'end_date' => e.end_date,
        'start_time' => e.start_time,
        'end_time' => e.end_time,
        'price' => e.price_type == 'free'? '0' : e.price, # check for price if it is zero
        'price_type' => e.price_type,
        'event_type' => e.event_type,
        'additional_media' => e.event_attachments,
        'location' => e.location,
        'lat' => e.lat,
        'lng' => e.lng,
        'image' => e.image,
        'is_interested' => is_interested?(e),
        'is_going' => is_attending?(e),
        'is_followed' => is_followed(e),
        'interest_count' => e.interested_interest_levels.size,
        'going_count' => e.going_interest_levels.size,
        'followers_count' => e.user ? e.user.followers.size : nil ,
        'following_count' => e.user ? e.user.followings.size : nil,
        'demographics' => get_demographics(e),
        'passes' =>  @passes,
        'ticket' => @ticket,
        'passes_grabbers_friends_count' =>  e.passes.map {|pass| pass.wallets.map { |wallet| if (request_user.friends.include? wallet.user) then wallet.user end } }.size,
        # 'going_users' => e.going_users,
        "interested_users" => getInterestedUsers(e),
        'creator_name' => e.user.first_name + " " + e.user.last_name,
        'creator_id' => e.user.id,
        'creator_image' => e.user.avatar.url,
        'categories' => !e.categories.blank? ? e.categories : @empty 
     }
     
    end #each

		render json: {
      code: 200,
      success: true,
      message: '',
			data: { 
       "events" =>  @events
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
      if @notification = Notification.create(recipient: user, actor: request_user, action: User.get_full_name(request_user) + " posted a new event.", notifiable: @event, url: '/admin/events', notification_type: 'web')  
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: user.device_token,
          type: 'gcm',
          add: user.device_token
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
         channel: [user.device_token],
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

  def update_setting
    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
    if !params[:mute_notifications].blank?
         mute_notifications = params[:mute_notifications]
      if  @event.event_setting.update!(mute_notifications: mute_notifications,user_id: request_user.id)
      render json: {
        code: 200,
        success: true,
        message: 'setting successfully updated.',
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'setting was not updated.',
        data: nil
      }
    end
    elsif  !params[:mute_chat].blank?
         mute_chat = params[:mute_chat]
      if  @event.event_setting.update!(mute_chat: mute_chat,user_id: request_user.id)
      render json: {
        code: 200,
        success: true,
        message: 'setting successfully updated.',
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'setting was not updated.',
        data: nil
      }
    end
    elsif(!params[:mute_chat].blank? && !params[:mute_notifications].blank?)
      if  @event.event_setting.update!(mute_chat: mute_chat, mute_notifications: mute_notifications,user_id: request_user.id)
      render json: {
        code: 200,
        success: true,
        message: 'setting successfully updated.',
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'setting was not updated.',
        data: nil
      }
    end
    else
      render json: {
        code: 400,
        success: false,
        message: 'Either mute_notifications or mute_chat is required.',
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: 'event_id is required.',
      data: nil
    }
  end
  end

  


  private 

  def getInterestedUsers(event)
    @interested_users = []
    @interested_followers = []
    @interested_others = []
    event.interested_users.uniq.each do |user|
     if (request_user.friends.include? user)
       @interested_followers.push(user) 
    else
       @interested_others.push(user)
     end
  end
  @interested_users << {
    "interested_friends" => @interested_followers,
    "interested_others" => @interested_others
  }
  @interested_users
  end

  def is_attending?(event)
    if request_user.events_to_attend.include? event
      true
    else
      false
    end
  end

  def is_interested?(event)
    if request_user.interested_in_events.include? event
      true
    else
      false
    end
  end

  def is_added_to_wallet?(pass_id)
    wallet = request_user.wallets.where(offer_id: pass_id).where(offer_type: 'Pass')
    if !wallet.blank?
      true
    else
      false
    end
  end

  def is_followed(event)
   request_user.followings.include? event.user
  end

   def is_ticket_purchased(ticket_id)
      ticket = TicketPurchase.where(user_id: request_user.id).where(ticket_id: ticket_id)
      if !ticket.blank?
        true
      else
        false
      end
   end

  # calculates interest level demographics interested + going
 
	def event_params
		params.permit(:name,:date,:start_time, :end_time, :external_link, :host, :description,:location,:image, :feature_media_link, :additinal_media, :allow_chat,:invitees,:event_forwarding,:allow_additional_media,:over_18)
  end
end
