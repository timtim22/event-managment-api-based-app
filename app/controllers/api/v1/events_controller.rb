class Api::V1::EventsController < Api::V1::ApiMasterController
  before_action :authorize_request, except:  ['events_list_by_date','index','show_event','get_map_events']

  api :POST, '/api/v1/events/show', 'To view a specific event'
  param :event_id, String, :desc => "Event ID", :required => true

  def show_event

    if !params[:event_id].blank?
      e = Event.find(params[:event_id])
      @passes = []
          @ticket = []
          all_pass_added = false
          if request_user
            all_pass_added = has_passes?(e) && all_passes_added_to_wallet?(request_user, e.passes)
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
          issued_by: get_full_name(pass.user),
          redeem_count: get_redeem_count(pass),
          quantity: pass.quantity
        }
      }# passes map
      end #if request_user

          @event = {
            'id' => e.id,
            'name' => e.name,
            'description' => e.description,
            'start_date' => e.start_date,
            'end_date' => e.end_date,
            'start_time' => e.start_time,
            'end_time' => e.end_time,
            'price' => get_price(e), # check for price if it is zero
            'price_type' => get_price_type(e),
            'event_type' => e.event_type,
            'additional_media' => e.event_attachments,
            'location' => insert_space_after_comma(e.location),
            'lat' => e.lat,
            'lng' => e.lng,
            'image' => e.image,
            'is_interested' => is_interested?(e),
            'is_going' => is_attending?(e),
            'is_followed' => is_followed(e.user),
            'interest_count' => e.interested_interest_levels.size,
            'going_count' => e.going_interest_levels.size,
            'demographics' => get_demographics(e),
            'going_users' => e.going_users,
            "interested_users" => getInterestedUsers(e),
            'creator_name' => e.user.business_profile.profile_name,
            'creator_id' => e.user.id,
            'creator_image' => e.user.avatar,
            'categories' => !e.categories.blank? ? e.categories : @empty,
            'sponsors' => e.sponsors,
            "mute_chat" => get_mute_chat_status(e),
            "mute_notifications" => get_mute_notifications_status(e),
            "terms_and_conditions" => e.terms_conditions,
            "forwards_count" => e.event_forwardings.count,
            "comments_count" => e.comments.size + e.comments.map {|c| c.replies }.size,
            "has_passes" => has_passes?(e),
            "all_passes_added_to_wallet" => all_pass_added
         }

         render json: {
           code: 200,
           success: true,
           message: '',
           user: request_user,
           data: {
             event: @event,
             #business_all_events: e.user.events.sort_by_date.page(params[:page]).per(10).map {|e| get_simple_event_object(e) }
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

  api :get, '/api/v1/events', 'Get events by list'


  def index
       cats_id = []
      if !params[:price].blank?
          case
          when params[:price].to_i == 0
            operator = "="
          when params[:price].to_i == 60
            operator = "<"
          when params[:price].to_i > 60
            operator = ">"
          when params[:price].to_i < 60
            operator = "<"
          else
            "do nothing"
          end
        end
        if !params[:categories].blank?

          cats_ids = params[:categories].split(",").map {|s| s.to_i }
        end

        if !params[:location].blank?

          location = trim_space(params[:location])
        else
          location = nil
        end

        #all events 1
        @events = Event.not_expired

        #location based events 2
        @events = Event.ransack(location_cont: location).result(distinct: true) if !params[:location].blank?

        # price based events 3
         @events =  Event.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).or(Event.where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(Event.where("price < ?", 1).where("end_price #{operator} ?", params[:price]))) if !params[:price].blank?

         #categories 3
         @events = Event.where(first_cat_id: cats_ids) if !params[:categories].blank?

         #has passes  4
         @events = Event.where(pass: 'true') if !params[:pass].blank?

         #location && price 5
         @events = Event.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).or(Event.where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(Event.where("price < ?", 1).where("end_price #{operator} ?", params[:price]))).ransack(location_cont: location).result(distinct: true)  if !params[:location].blank? && !params[:price].blank?

         # locatiion && categories 6
          @events = Event.where(first_cat_id: cats_ids).ransack(location_cont: location).result(distinct: true) if !params[:location].blank? && !params[:categories].blank?

          #location && pass 7
          @events = Event.where(pass: 'true').ransack(location_cont: location).result(distinct: true) if !params[:location].blank? && !params[:pass].blank?

           #price && categories 8
           @events = Event.where(first_cat_id: cats_ids).where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).or(Event.where(first_cat_id: cats_ids).where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(Event.where(first_cat_id: cats_ids).where("price < ?", 1).where("end_price #{operator} ?", params[:price]))) if !params[:categories].blank? && !params[:price].blank?

           #price && pass 9
           @events = Event.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).where(pass: 'true').or(Event.where(pass: "true").where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(Event.where(pass: "true").where("price < ?", 1).where("end_price #{operator} ?", params[:price]))) if !params[:price].blank? && !params[:pass].blank?

            #categories && pass 10
            @events = Event.where(pass: 'true').where(first_cat_id: cats_ids) if !params[:categories].blank? && !params[:pass].blank?

             #location ,categories, price 11
             @events = Event.where(first_cat_id: cats_ids).where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).or(Event.where(first_cat_id: cats_ids).where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(Event.where(first_cat_id: cats_ids).where("price < ?", 1).where("end_price #{operator} ?", params[:price]))).ransack(location_cont: location).result(distinct: true) if !params[:location].blank? && !params[:categories].blank? && !params[:price].blank?

              #location ,pass, price 12
              @events = Event.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).where(pass: 'true').or(Event.where(pass: "true").where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(Event.where(pass: "true").where("price < ?", 1).where("end_price #{operator} ?", params[:price]))).ransack(location_cont: location).result(distinct: true) if !params[:price].blank? && !params[:pass].blank? && !params[:location].blank?

              #location ,pass, categories 13
              @events = Event.where(pass: 'true').where(first_cat_id: cats_ids).ransack(location_cont: location).result(distinct: true) if !params[:categories].blank? && !params[:pass].blank? && !params[:categories].blank?

              #location ,pass, categories, price 14
              @events = Event.where("price #{operator} ?", params[:price]).where("start_price < ?", 1).where("end_price < ?", 1).where(pass: 'true').where(first_cat_id: cats_ids).or(Event.where(pass: "true").where(first_cat_id: cats_ids).where("price < ?", 1).where("start_price #{operator} ?", params[:price]).or(Event.where(pass: "true").where(first_cat_id: cats_ids).where("price < ?", 1).where("end_price #{operator} ?", params[:price]))).ransack(location_cont: location).result(distinct: true) if !params[:price].blank? && !params[:pass].blank? && !params[:location].blank? && !params[:categories].blank?

              @response = @events.sort_by_date.page(params[:page]).per(75).map {|event| get_simple_event_object(event) }

              render json: {
                code: 200,
                size: @response.size,
                operator: operator,
                cats_ids: cats_ids,
                success: true,
                data:  {
                  events: @response
                }
              }

    end #func

  api :POST, '/api/v1/events-by-date', 'Get events by date'
  param :date, String, :desc => "Date", :required => true

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

  # def create
  #   @event = Event.new(event_params)
  #   # Notify all mygo user about event creation
  #   @pubnub = Pubnub.new(
  #     publish_key: ENV['PUBLISH_KEY'],
  #     subscribe_key: ENV['SUBSCRIBE_KEY']
  #   )
  #   (User.all - [request_user]).each do |user|

  #     if @notification = Notification.create(recipient: user, actor: request_user, action: get_full_name(request_user) + " posted a new event.", notifiable: @event, resource: @event, url: '/admin/events', notification_type: 'web')
  #       @current_push_token = @pubnub.add_channels_to_push(
  #         push_token: user.profile.device_token,
  #         type: 'gcm',
  #         add: user.profile.device_token
  #         ).value

  #       payload = {
  #       "pn_gcm":{
  #         "notification":{
  #           "title": @notification.action,
  #         },
  #         "type": @notification.notifiable_type,
  #         "event_id": @event.id
  #       }
  #     }

  #       @pubnub.publish(
  #        channel: [user.profile.device_token],
  #        message: payload
  #         ) do |envelope|
  #           puts envelope.status
  #       end
  #     end ##notification create
  #   end #each
	# 	if @event.save
	# 		render json: {
	# 			status: true,
	# 			message: "Event successfully created."
	# 		}

	# 	else
	# 	    render json: {
	# 	    	status: false,
	# 	    	message: @event.errors.full_messages
	# 	    }
	# 	end
  # end

  api :POST, '/api/v1/event/report-event', 'To repot an event'
  param :event_id, :number, :desc => "Event ID", :required => true
  param :reason, String, :desc => "Reason for reporting an event", :required => true


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

  api :POST, '/api/v1/event/create-view', 'To create view'
  param :event_id, :number, :desc => "Event ID", :required => true

  def create_view
    if !params[:event_id].blank?
      event = Event.find(params[:event_id])
    if view = event.views.create!(user_id: request_user.id, business_id: event.user.id)
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

  api :POST, '/api/v1/get-business-events', 'Get a business user events'
  param :business_id, :number, :desc => "Business ID", :required => true

  def get_business_events
    if !params[:business_id].blank?
      business = User.find(params[:business_id])
      events =  business.events.page(params[:page]).per(30).map { |e| get_simple_event_object(e) }
        render json: {
          code: 200,
          success:true,
          message: '',
          data: {
            events: events
          }
        }

    else
      render json: {
        code: 400,
        success:false,
        message: "business_id is required field.",
        data: nil
      }
    end
  end


  def get_map_events
    if !params[:date].blank?
      date = Date.parse(params[:date])
      @events = Event.where(start_date:  date.midnight..date.end_of_day)
      events  = @events.map {|event| get_map_event_object(event) }
      render json: {
        code: 200,
        success: true,
        message: "",
        data: {
          events: events
        }
      }
    else
      render json: {
        code: 400,
        success: false,
        message: "date is required field.",
        data: nil
      }
  end
  end



  private


 def get_map_event_object(event)
    event = {
      "id" => event.id,
      "lat" => event.lat,
      "lng" => event.lng,
      "price_type" => event.price_type,
      "max_price" => get_max_price(event),
      "has_passes" => has_passes?(event),
      "categories" => event.categories
    }
 end

  # calculates interest level demographics interested + going

	def event_params
		params.permit(:name,:date,:start_time, :end_time, :external_link, :terms_conditions, :host, :description,:location,:image, :feature_media_link, :additinal_media, :allow_chat,:invitees,:event_forwarding,:allow_additional_media,:over_18)
  end
end
