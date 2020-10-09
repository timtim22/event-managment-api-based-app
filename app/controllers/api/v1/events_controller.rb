class Api::V1::EventsController < Api::V1::ApiMasterController
  before_action :authorize_request, except:  ['events_list_by_date','index','show_event']

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
            'location' => e.location,
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
            "comments_count" => e.comments.size,
            "has_passes" => has_passes?(e) 
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
  
  # def index
  #   @events = []
  #   if !params[:filter_names].blank?
  #     filter_names = params[:filter_names].split(',').map {|s| s } 
  #     filter_names.each do  |name|
  #      case name
  #       when "location"
  #         @q = Event.ransack(location_cont: params[:location])
  #          events = @q.result(distinct: true).page(params[:page]).per(30)
  #         if !events.blank?
  #           events.page(params[:page]).per(30).map {|event| @events.push(get_simple_event_object(event)) }
  #         end
  #       when "price"
         
  #         case 
  #         when params[:price].to_i == 0
  #           events = Ticket.where(ticket_type: 'free').page(params[:page]).per(30).map {|ticket| ticket.event  }
  #           if !events.blank?
  #            events.map {|event| @events.push(get_simple_event_object(event)) }
  #           end
  #         when params[:price].to_i < 60
  #           @buy_events = Ticket.where(ticket_type: 'buy').where("price < ?", 60).page(params[:page]).per(30).map {|ticket| ticket.event  }
  #           if !@buy_events.blank?
  #             @buy_events.map {|event| @events.push(get_simple_event_object(event)) }
  #           end 
  
  #            @pay_at_door_events = Ticket.where(ticket_type: 'pay_at_door').where("end_price < ?", 60).page(params[:page]).per(30).map {|ticket| ticket.event  }
  #           if !@pay_at_door_events.blank?
  #             @pay_at_door_events.map {|event| @events.push(get_simple_event_object(event)) }
  #           end 
  #         when params[:price].to_i > 60
  #           @buy_events = Ticket.where(ticket_type: 'buy').where("price > ?", 60).page(params[:page]).per(30).map {|ticket| ticket.event  }
  #           if !@buy_events.blank?
  #             @buy_events.map {|event| @events.push(get_simple_event_object(event)) }
  #           end 
  
  #            @pay_at_door_events = Ticket.where(ticket_type: 'pay_at_door').where("end_price > ?", 60).page(params[:page]).per(30).map {|ticket| ticket.event  }
  #           if !@pay_at_door_events.blank?
  #             @pay_at_door_events.map {|event| @events.push(get_simple_event_object(event)) }
  #           end 
  #         else
  #           "do nothing"
  #         end

  #       when "categories"
  #           events = []
  #           categories = params[:categories].split(',').map {|id|  Category.find_by(uuid: id) }
  #           categorizations = categories.map {|cat| Categorization.find_by(category_id: cat.id) }
      
  #          if categorizations !=  [nil]
  #            categorizations.each do |categorization|         
  #             @events.push(get_simple_event_object(categorization.event))
  #            end   
  #          end
  #         when "pass"
  #           events = Pass.page(params[:page]).per(30).map {|pass| pass.event }
  #           if !events.blank?
  #             events.map {|event| @events.push(get_simple_event_object(event)) }
  #           end   
  #       else
  #          "do nothing for now"
  #       end #switch
  #     end #each
  #   else
  #     events = Event.sort_by_date.page(params[:page]).per(30).eager_load(:passes, :tickets)
  #     @events = events.map {|event| get_simple_event_object(event) }
  #   end

  #   @result = paginate_array(@events).page(params[:page]).per(30)
  #   render json: {
  #       code: 200,
  #       success: true,
  #       message: '',
  #       data: { 
  #         "events" => array_sort_by_date(@result)
  #       }
  #     }
  # end


  # def index
  #   if params[:filter] == 'true'
  #     first_cat = ''
  #   if !params[:categories].blank? 
      
  #     cat_names = params[:categories].split(',').map {|s| s }
  #     first_cat = cat_names[0]
  #     @events = Event.joins(:categories).ransack(:location_cont => params[:location]).result(distinct: true).ransack(pass_cont: params[:pass]).result(distinct: true).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).uniq.map {|event| get_simple_event_object(event) }
  #   else
   
  #   if !params[:price].blank?
     
  #     if params[:price].to_i == 0
       
  #       @events = Event.ransack(location_cont: params[:location]).result(distinct: true).ransack(pass_cont: params[:pass]).result(distinct: true).merge(Ticket.ransack(ticket_type_cont: 'free').result(distinct: true)).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).page(params[:page]).per(30).uniq.map {|event| get_simple_event_object(event) }

  #     elsif params[:price].to_i < 20

  #       @events = Event.ransack(location_cont: params[:location]).result(distinct: true).ransack(pass_cont: params[:pass]).result(distinct: true).merge(Ticket.ransack(price_lt: 20).result(distinct: true)).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).page(params[:page]).per(30).uniq.map {|event| get_simple_event_object(event) }

  #     elsif params[:price].to_i < 30
  #       @events = Event.ransack(location_cont: params[:location]).result(distinct: true).ransack(pass_cont: params[:pass]).result(distinct: true).merge(Ticket.ransack(price_lt: 30).result(distinct: true)).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).page(params[:page]).per(30).uniq.map {|event| get_simple_event_object(event) }

        
  #     elsif params[:price].to_i < 40
  #       @events = Event.ransack(location_cont: params[:location]).result(distinct: true).ransack(pass_cont: params[:pass]).result(distinct: true).merge(Ticket.ransack(price_lt: 40).result(distinct: true)).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).page(params[:page]).per(30).uniq.map {|event| get_simple_event_object(event) }

  #     elsif params[:price].to_i < 50
  #       @events = Event.ransack(location_cont: params[:location]).result(distinct: true).ransack(pass_cont: params[:pass]).result(distinct: true).merge(Ticket.ransack(price_lt: 50).result(distinct: true)).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).page(params[:page]).per(30).uniq.map {|event| get_simple_event_object(event) }
     
  #     elsif params[:price].to_i > 60
  #       @events = Event.ransack(location_cont: params[:location]).result(distinct: true).ransack(pass_cont: params[:pass]).result(distinct: true).merge(Ticket.ransack(price_gt: 60).result(distinct: true)).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).page(params[:page]).per(30).uniq.map {|event| get_simple_event_object(event) }
     
  #     elsif params[:price].to_i < 60  
  #       @events =Event.ransack(location_cont: params[:location]).result(distinct: true).ransack(pass_cont: params[:pass]).result(distinct: true).merge(Ticket.ransack(price_lt: 60).result(distinct: true)).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).page(params[:page]).per(30).uniq.map {|event| get_simple_event_object(event) } 
  #     end

   
     
  #   else
   
      
  #     @events = Event.ransack(location_cont: params[:location]).result(distinct: true).ransack(pass_cont: params[:pass]).result(distinct: true).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).page(params[:page]).per(30).uniq.map {|event| get_simple_event_object(event) }
  #   end

  # end
   
  #   else

    
  #     events = Event.sort_by_date.page(params[:page]).per(30).eager_load(:passes, :tickets)
  #     @events = events.map {|event| get_simple_event_object(event) }  
  #   end

  #   render json:  {
  #     code: 200,
  #     success: true,
  #     message: '',
  #     size: @events.size,
  #     params: params,
  #     first_cat: cat_names,
  #     data: {
  #       events: @events,
        
  #     }
  #   }
  # end



  def index

    if params[:filter] == 'true'
      price = ''
      first_cat = ''
      predicate = ''

      if !params[:categories].blank? 
        cat_names = params[:categories].split(',').map {|s| s }
        first_cat = cat_names[0]
      end

      if !params[:price].blank?
          case 
          when params[:price].to_i == 0
            price = '0.00'
            predicate = 'price_eq'
          when params[:price].to_i > 60
            price = '60'
            predicate = 'price_gt'
          when params[:price].to_i < 60
            price = '60'
            predicate = 'price_lt'
          when params[:price].to_i < 50
            price = '50'
            predicate = 'price_lt'
          when params[:price].to_i < 40
            price = '40'
            predicate = 'price_lt'
          when params[:price].to_i < 30
            price = '30'
            predicate = 'price_lt'
          when params[:price].to_i < 20
           price = '20'
           predicate = 'price_lt'
          else
            "do nothing"
          end
      end #if

      predicate_sym = string_to_sym(predicate)
      
      @events = Event.all.joins(:tickets, :categories).ransack(pass_cont: params[:pass]).result(distinct: true).ransack(location_cont: params[:location]).result(distinct: true).merge(Ticket.ransack(ticket_type_cont: 'free').result(distinct: true)).merge(Category.ransack(name_cont: first_cat).result(distinct: true)).page(params[:page]).per(30).uniq.map {|event| get_simple_event_object(event) }

    else
      events = Event.sort_by_date.page(params[:page]).per(30).eager_load(:passes, :tickets)
      @events = events.map {|event| get_simple_event_object(event) }  
    end

      

      render json:  {
        code: 200,
        success: true,
        message: '',
        size: @events.size,
        params: params,
        data: {
          events: @events,
          
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
