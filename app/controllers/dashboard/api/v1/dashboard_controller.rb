class Dashboard::Api::V1::DashboardController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request
  before_action :checkout_logout
  before_action :business


  def get_dashboard_stats
    if !params[:business_id].blank? && !params[:current_time_slot_dates].blank?

      @business = User.find(params[:business_id])

      stats = []
      @business.events.each do |event|
      stats << {
        "total_going" => get_time_slot_total_going(params[:current_time_slot_dates], event),
        "total_going_date_wise" => get_time_slot_going_date_wise(params[:current_time_slot_dates], event),
        "total_maybe" => get_time_slot_total_maybe(params[:current_time_slot_dates], event),
        "total_maybe_date_wise" => get_time_slot_maybe_date_wise(params[:current_time_slot_dates], event)
      }
    end

    stats << {
        "total_events" => get_time_slot_total_events(params[:current_time_slot_dates], @business),
        "total_passes" => get_time_slot_total_passes(params[:current_time_slot_dates], @business),
        "total_special_offers" => get_time_slot_total_special_offers(params[:current_time_slot_dates], @business),
        "total_competitions" => get_time_slot_total_competitions(params[:current_time_slot_dates], @business),
        "total_ambassadors" => get_time_slot_total_ambassadors(params[:current_time_slot_dates], @business),
        "total_views" => get_time_slot_total_views(params[:current_time_slot_dates], @business),
        "total_views_date_wise" => get_time_slot_views_date_wise(params[:current_time_slot_dates], @business),
        "total_comments" => get_time_slot_total_comments(params[:current_time_slot_dates], @business),
        "total_comments_date_wise" => get_time_slot_comments_date_wise(params[:current_time_slot_dates], @business),
        "total_followers" => get_time_slot_total_followers(params[:current_time_slot_dates], @business),
        "total_followers_date_wise" => get_time_slot_followers_date_wise(params[:current_time_slot_dates], @business),
        "total_shares" => get_time_slot_total_shares(params[:current_time_slot_dates], @business),
        "total_shares_date_wise" => get_time_slot_shares_date_wise(params[:current_time_slot_dates], @business)
    }
    render json: {
      code: 200,
      success: true,
      message: 'Dashboard Stats',
      data: {
        stats: stats
      }
        }
  else
      render json: {
        code: 400,
        success: false,
        message: 'business_id and current_time_slot_dates are required.',
        data: nil
      }
    end #if
   # def total_events
end
   # end

  def get_parent_event_stats
    if !params[:event_id].blank? && !params[:current_time_slot_dates].blank?
      @event = []
      e = Event.find(params[:event_id])
      case
      when e.price_type == "free_event" || e.price_type == "free"
        @event = {
          location: e.location,
          start_date: e.start_date,
          Impressions: get_time_slot_parent_total_views(params[:current_time_slot_dates], e),
          Comments: get_time_slot_parent_event_total_comments(params[:current_time_slot_dates], e),
          Ambassadors: get_time_slot_user_event_ambassadors(params[:current_time_slot_dates], e),
          New_followers: get_time_slot_user_event_followers(params[:current_time_slot_dates], e),
          total_going_date_wise: get_time_slot_parent_event_total_going(params[:current_time_slot_dates], e),
          total_interested_date_wise: get_time_slot_parent_event_total_interested(params[:current_time_slot_dates], e),
          # recent_activity: get_time_slot_interestlevel_recent_activity(params[:current_time_slot_dates], e)
          recent_activity: e.child_events.map { |e| e.interest_levels.last(4).map { |i| {level: i.level, user: i.user.id } }}
        }
      when e.price_type == "paid"
        @event = {
          location: e.location,
          start_date: e.start_date,
          price: e.tickets.first.price,   
          Comments: get_time_slot_parent_event_total_comments(params[:current_time_slot_dates], e),
          New_followers: get_time_slot_user_event_followers(params[:current_time_slot_dates], e),
          Ambassadors: get_time_slot_user_event_ambassadors(params[:current_time_slot_dates], e),
          Impressions: get_time_slot_parent_total_views(params[:current_time_slot_dates], e),
          # Tickets: get_time_slot_parent_event_ticket(params[:current_time_slot_dates], e)
          Tickets: e.tickets.first.quantity,
          passes_in_wallets: e.passes.map { |e| e.wallets }.size,
          recent_sales: TicketPurchase.where(ticket_id: e.tickets.first.id).map { |e| {user: e.user.id, quantity: e.quantity, price: e.price} }.last(4)
          }
      when e.price_type == "pay_at_door"
          @event = {
          location: e.location,
          start_date: e.start_date,
          Impressions: get_time_slot_parent_total_views(params[:current_time_slot_dates], e),
          Comments: get_time_slot_parent_event_total_comments(params[:current_time_slot_dates], e),
          Ambassadors: get_time_slot_user_event_ambassadors(params[:current_time_slot_dates], e),
          New_followers: get_time_slot_user_event_followers(params[:current_time_slot_dates], e),
          total_going_date_wise: get_time_slot_parent_event_total_going(params[:current_time_slot_dates], e),
          total_interested_date_wise: get_time_slot_parent_event_total_interested(params[:current_time_slot_dates], e),
          recent_activity: e.child_events.map { |e| e.interest_levels.last(4).map { |i| {level: i.level, user: i.user.id } }},
          passes_in_wallets: e.passes.map { |e| e.wallets }.size
          }
      end
    
      render json: {
        code: 200,
        success: true,
        message: 'Parent Event Stats',
        data: {
          stats: @event
        }
          }
    else
        render json: {
          code: 400,
          success: false,
          message: 'business_id and current_time_slot_dates are required.',
          data: nil
        }
      end #if
   # def total_events
end


def get_live_event_data
  if !params[:event_id].blank?
    e = ChildEvent.find(params[:event_id])
    @attendees = []
    @event = []
    if e.start_date.to_date == Date.today
      if e.price_type == "free_event" || e.price_type == "pay_at_door"
        e.going_interest_levels.each do |going|
        @attendees << {
          user:  get_full_name(going.user),
          avatar:  going.user.avatar,
          confirmation_date:  going.created_at.to_date,
          ticket_title:  "",
          quantity:  "",
          paid:  "",
          is_ambassador:  going.user.profile.is_ambassador,
          type:  "",
          check_in_way:  "",
          check_in_time:  ""
        }
        end
      else
        tickets = e.event.tickets.pluck :id
        passes = e.event.passes.pluck :id
        ids = tickets + passes
        Redemption.where(offer_id: ids).each do |going|
        @attendees << {
          user:  get_full_name(going.user),
          avatar:  going.user.avatar,
          confirmation_date:  going.created_at.to_date,
          ticket_title:  going.offer.title,
          quantity:  going.user.redemptions.size,
          paid:  get_redem_price(going),
          is_ambassador:  going.user.profile.is_ambassador,
          type:  get_redemption_type(going),
          check_in_way:  "QR",
          check_in_time:  goin.created_at
        }
        end
      end
          @event << {
            time_remaning: "Live Now",
            location: eval(e.location),
            date: e.start_date,
            going: e.going_interest_levels.size,
            passes_in_wallets: e.event.passes.map { |e| e.wallets }.size,
            vip_pass: e.event.passes.where(pass_type: "vip").map {|e| e.quantity}.sum,
            tickets: e.event.tickets.map { |e|  e.ticket_purchases.map {|e| e.quantity}.sum}.sum.to_s + " of " + e.event.tickets.map { |e|  e.quantity}.sum.to_s,
            tickets_percentage: (e.event.tickets.map { |e|  e.ticket_purchases.map {|e| e.quantity}.sum}.sum.to_i/(e.event.tickets.map { |e|  e.quantity}.sum.to_i.to_f.nonzero? || 1) * 100).to_i.to_s, 
            guest_passes: e.event.passes.where(pass_type: "ordinary").map {|e| e.redemptions}.size.to_s + " of " + e.event.passes.where(pass_type: "ordinary").size.to_s,
            guest_passes_percentage: (e.event.passes.where(pass_type: "ordinary").map {|e| e.redemptions}.size.to_i.to_f/(e.event.passes.where(pass_type: "ordinary").size.to_i.nonzero? || 1) * 100).to_i.to_s, 
            vip_passes: e.event.passes.where(pass_type: "vip").map {|e| e.redemptions}.size.to_s + " of " + e.event.passes.where(pass_type: "vip").size.to_s,
            vip_passes_percentage: (e.event.passes.where(pass_type: "vip").map {|e| e.redemptions}.size.to_i/(e.event.passes.where(pass_type: "vip").size.to_i.nonzero? || 1) * 100).to_i.to_s,
            attendees: @attendees 
          }
    end
      render json: {
        code: 200,
        success: true,
        message: 'Child Event Stats',
        data: {
          stats: @event
        }
          }

  else
      render json: {
        code: 400,
        success: false,
        message: 'event_id',
        data: nil
      }
  end #if

end

def get_child_event_attendees_stats
    if !params[:event_id].blank? 
      e = ChildEvent.find(params[:event_id])
        @attendees = []
        @event = []
        #extract attendees from ticket purchases       
        case
        when e.start_date.to_date < Date.today

          if e.price_type == "free_event" || e.price_type == "pay_at_door"
            e.going_interest_levels.each do |going|
            @attendees << {
              user:  get_full_name(going.user),
              avatar:  going.user.avatar,
              confirmation_date:  going.created_at.to_date,
              ticket_title:  "",
              quantity:  "",
              paid:  "",
              is_ambassador:  going.user.profile.is_ambassador,
              type:  "",
              check_in_way:  "",
              check_in_time:  ""
            }
          end
          else
          tickets = TicketPurchase.all.map { |e| e.ticket}.select {|m| m.event_id == e.event.id}
            tickets.map {|m| m.ticket_purchases.each do |going| 
            @attendees << {
              user:  get_full_name(going.user),
              avatar:  going.user.avatar,
              confirmation_date:  going.created_at.to_date,
              ticket_title:  going.ticket.title,
              quantity:  going.quantity,
              paid:  going.price,
              is_ambassador:  going.user.profile.is_ambassador,
              type:  "",
              check_in_way:  "",
              check_in_time:  ""
            }
          end
        }
          end

          @event << {
            time_remaning: (e.start_date.to_date - Date.today).to_i.to_s + " days remaning",
            location: eval(e.location),
            date: e.start_date,
            going: e.going_interest_levels.size,
            passes_in_wallets: e.event.passes.map { |e| e.wallets }.size,
            vip_pass: e.event.passes.where(pass_type: "vip").map {|e| e.quantity}.sum,
            tickets: e.event.tickets.map { |e|  e.ticket_purchases.map {|e| e.quantity}.sum}.sum.to_s + " of " + e.event.tickets.map { |e|  e.quantity}.sum.to_s,
            tickets_percentage: (e.event.tickets.map { |e|  e.ticket_purchases.map {|e| e.quantity}.sum}.sum.to_i/(e.event.tickets.map { |e|  e.quantity}.sum.to_i.to_f.nonzero? || 1) * 100).to_i.to_s, 
            guest_passes: e.event.passes.where(pass_type: "ordinary").map {|e| e.redemptions}.size.to_s + " of " + e.event.passes.where(pass_type: "ordinary").size.to_s,
            guest_passes_percentage: (e.event.passes.where(pass_type: "ordinary").map {|e| e.redemptions}.size.to_i.to_f/(e.event.passes.where(pass_type: "ordinary").size.to_i.nonzero? || 1) * 100).to_i.to_s, 
            vip_passes: e.event.passes.where(pass_type: "vip").map {|e| e.redemptions}.size.to_s + " of " + e.event.passes.where(pass_type: "vip").size.to_s,
            vip_passes_percentage: (e.event.passes.where(pass_type: "vip").map {|e| e.redemptions}.size.to_i/(e.event.passes.where(pass_type: "vip").size.to_i.nonzero? || 1) * 100).to_i.to_s,
            attendees: @attendees 
          }
        when e.start_date.to_date == Date.today
          if e.price_type == "free_event" || e.price_type == "pay_at_door"
            e.going_interest_levels.each do |going|
            @attendees << {
              user:  get_full_name(going.user),
              avatar:  going.user.avatar,
              confirmation_date:  going.created_at.to_date,
              ticket_title:  "",
              quantity:  "",
              paid:  "",
              is_ambassador:  going.user.profile.is_ambassador,
              type:  "",
              check_in_way:  "",
              check_in_time:  ""
            }
          end
          else
          tickets = TicketPurchase.all.map { |e| e.ticket}.select {|m| m.event_id == e.event.id}
            tickets.map {|m| m.ticket_purchases.each do |going| 
            @attendees << {
              user:  get_full_name(going.user),
              avatar:  going.user.avatar,
              confirmation_date:  going.created_at.to_date,
              ticket_title:  going.ticket.title,
              quantity:  going.quantity,
              paid:  going.price,
              is_ambassador:  going.user.profile.is_ambassador,
              type:  "",
              check_in_way:  "",
              check_in_time:  ""
            }
          end
        }
          end
          @event << {
            time_remaning: "Live Now",
            location: eval(e.location),
            date: e.start_date,
            going: e.going_interest_levels.size,
            passes_in_wallets: e.event.passes.map { |e| e.wallets }.size,
            vip_pass: e.event.passes.where(pass_type: "vip").map {|e| e.quantity}.sum,
            tickets: e.event.tickets.map { |e|  e.ticket_purchases.map {|e| e.quantity}.sum}.sum.to_s + " of " + e.event.tickets.map { |e|  e.quantity}.sum.to_s,
            tickets_percentage: (e.event.tickets.map { |e|  e.ticket_purchases.map {|e| e.quantity}.sum}.sum.to_i/(e.event.tickets.map { |e|  e.quantity}.sum.to_i.to_f.nonzero? || 1) * 100).to_i.to_s,
            guest_passes: e.event.passes.where(pass_type: "ordinary").map {|e| e.redemptions}.size.to_s + " of " + e.event.passes.where(pass_type: "ordinary").size.to_s,
            guest_passes_percentage: (e.event.passes.where(pass_type: "ordinary").map {|e| e.redemptions}.size.to_i.to_f/(e.event.passes.where(pass_type: "ordinary").size.to_i.nonzero? || 1) * 100).to_i.to_s,
            vip_passes: e.event.passes.where(pass_type: "vip").map {|e| e.redemptions}.size.to_s + " of " + e.event.passes.where(pass_type: "vip").size.to_s,
            vip_passes_percentage: (e.event.passes.where(pass_type: "vip").map {|e| e.redemptions}.size.to_i/(e.event.passes.where(pass_type: "vip").size.to_i.nonzero? || 1) * 100).to_i.to_s,
            attendees: @attendees 
          }
        when e.start_date.to_date > Date.today
          if e.price_type == "free_event" || e.price_type == "pay_at_door"
            e.going_interest_levels.each do |going|
            @attendees << {
              user:  get_full_name(going.user),
              avatar:  going.user.avatar,
              confirmation_date:  going.created_at.to_date,
              ticket_title:  "",
              quantity:  "",
              paid:  "",
              is_ambassador:  going.user.profile.is_ambassador,
              check_in_way:  "",
              check_in_time:  ""
            }
          end
          else
          tickets = TicketPurchase.all.map { |e| e.ticket}.select {|m| m.event_id == e.event.id}
            tickets.map {|m| m.ticket_purchases.each do |going| 
            @attendees << {
              user:  get_full_name(going.user),
              avatar:  going.user.avatar,
              confirmation_date:  going.created_at.to_date,
              ticket_title:  going.ticket.title,
              quantity:  going.quantity,
              paid:  going.price,
              is_ambassador:  going.user.profile.is_ambassador,
              type:  "",
              check_in_way:  "",
              check_in_time:  ""
            }
          end
        }
          end
        @event << {
          time_remaning: "Event Over",
          location: eval(e.location),
          date: e.start_date,
          going: e.going_interest_levels.size,
          passes_in_wallets: e.event.passes.map { |e| e.wallets }.size,
          vip_pass: e.event.passes.where(pass_type: "vip").map {|e| e.quantity}.sum,
          tickets: e.event.tickets.map { |e|  e.ticket_purchases.map {|e| e.quantity}.sum}.sum.to_s + " of " + e.event.tickets.map { |e|  e.quantity}.sum.to_s,
          tickets_percentage: (e.event.tickets.map { |e|  e.ticket_purchases.map {|e| e.quantity}.sum}.sum.to_i/(e.event.tickets.map { |e|  e.quantity}.sum.to_i.to_f.nonzero? || 1) * 100).to_i.to_s,
          guest_passes: e.event.passes.where(pass_type: "ordinary").map {|e| e.redemptions}.size.to_s + " of " + e.event.passes.where(pass_type: "ordinary").size.to_s,
          guest_passes_percentage: (e.event.passes.where(pass_type: "ordinary").map {|e| e.redemptions}.size.to_i.to_f/(e.event.passes.where(pass_type: "ordinary").size.to_i.nonzero? || 1) * 100).to_i.to_s,
          vip_passes: e.event.passes.where(pass_type: "vip").map {|e| e.redemptions}.size.to_s + " of " + e.event.passes.where(pass_type: "vip").size.to_s,
          vip_passes_percentage: (e.event.passes.where(pass_type: "vip").map {|e| e.redemptions}.size.to_i/(e.event.passes.where(pass_type: "vip").size.to_i.nonzero? || 1) * 100).to_i.to_s,
          attendees: @attendees 
        }
      end
      
      render json: {
        code: 200,
        success: true,
        message: 'Child_Event Stats',
        data: {
          stats: @event
        }
          }
    else
        render json: {
          code: 400,
          success: false,
          message: 'event_id',
          data: nil
        }
      end #if
 end





def get_child_event_full_analytics
    if !params[:event_id].blank? 
      @event = []
      e = ChildEvent.find(params[:event_id])
      case

      when e.start_date == Time.now.to_date
        # if e.price_type == "free_event"
        #   @event << {
        #     title: "FREE EVENT"
        #   }
        # elsif e.price_type == "free"
        #   @event << {
        #     title: "FREE TICKET"
        #   }
        # end
        @attendees = []
        @attendees << {


          attendees: TicketPurchase.where(ticket_id: e.event.tickets.first.id).map { |e| {
            user:  e.user_id,
            confirmation_date:  e.created_at.to_date,
            ticket_title:  e.ticket.title,
            quantity:  e.quantity,
            paid:  e.price,
            is_ambassador:  if @amb = !e.user.ambassador_requests.where(business_id: e.ticket.user_id).first.blank?
                               @amb
                            else
                                false
                            end
          }}}
        @event << {
          # title: "FREE EVENT" if e.price_type == "free_event",
          # title: "FREE TICKET" if e.price_type == "free",
          location: e.location,
          date: e.start_date,
          going: e.going_interest_levels.size,
          passes_in_wallets: e.event.passes.map { |e| e.wallets }.size,
          vip_pass: e.event.passes.where(pass_type: "vip").map {|e| e.quantity}.sum,
          tickets: e.event.tickets.first.ticket_purchases.map {|e| e.quantity}.sum.to_s + " of " + e.event.tickets.first.quantity.to_s,
          guest_passes: "" + " of " + e.event.passes.map {|e| e.quantity}.sum.to_s,
          vip_passes: "" + " of " + e.event.passes.where(pass_type: "vip").map {|e| e.quantity}.sum.to_s,
          attendees: @attendees 
        }
          # Ambassadors: get_time_slot_user_event_ambassadors(params[:current_time_slot_dates], e),
          # new_followers: get_time_slot_user_event_followers(params[:current_time_slot_dates], e),
          # total_going_date_wise: get_time_slot_child_event_total_going(params[:current_time_slot_dates], e),
          # total_interested_date_wise: get_time_slot_child_event_total_interested(params[:current_time_slot_dates], e),
          # recent_activity: e.interest_levels.last(4).map { |i| {level: i.level, user: i.user.id }}
          
      when e.price_type == "free_event" || e.price_type == "free"
        # if e.price_type == "free_event"
        #   @event << {
        #     title: "FREE EVENT"
        #   }
        # elsif e.price_type == "free"
        #   @event << {
        #     title: "FREE TICKET"
        #   }
        # end
        @event << {
          # title: "FREE EVENT" if e.price_type == "free_event",
          # title: "FREE TICKET" if e.price_type == "free",
          location: e.location,
          date: e.start_date,
          Impressions: get_time_slot_child_total_views(params[:current_time_slot_dates], e),
          Comments: get_time_slot_child_total_comments(params[:current_time_slot_dates], e),
          Ambassadors: get_time_slot_user_event_ambassadors(params[:current_time_slot_dates], e),
          new_followers: get_time_slot_user_event_followers(params[:current_time_slot_dates], e),
          total_going_date_wise: get_time_slot_child_event_total_going(params[:current_time_slot_dates], e),
          total_interested_date_wise: get_time_slot_child_event_total_interested(params[:current_time_slot_dates], e),
          recent_activity: e.interest_levels.last(4).map { |i| {level: i.level, user: i.user.id }}
          }
      when e.price_type == "paid"
        @event = {
          location: e.location,
          start_date: e.start_date,
          price: e.event.tickets.first.price,   
          Comments: get_time_slot_child_total_comments(params[:current_time_slot_dates], e),
          new_followers: get_time_slot_user_event_followers(params[:current_time_slot_dates], e),
          Ambassadors: get_time_slot_user_event_ambassadors(params[:current_time_slot_dates], e),
          Impressions: get_time_slot_child_total_views(params[:current_time_slot_dates], e),
          Tickets: e.event.tickets.first.quantity,
          passes_in_wallets: e.event.passes.map { |e| e.wallets }.size,
          recent_sales: TicketPurchase.where(ticket_id: e.event.tickets.first.id).map { |e| {user: e.user.id, quantity: e.quantity, price: e.price} }.last(4)
          }
        when e.price_type == "pay_at_door"
          @event = {
          location: e.location,
          start_date: e.start_date,
          Impressions: get_time_slot_child_total_views(params[:current_time_slot_dates], e),
          Comments: get_time_slot_child_total_comments(params[:current_time_slot_dates], e),
          Ambassadors: get_time_slot_user_event_ambassadors(params[:current_time_slot_dates], e),
          New_followers: get_time_slot_user_event_followers(params[:current_time_slot_dates], e),
          total_going_date_wise: get_time_slot_child_event_total_going(params[:current_time_slot_dates], e),
          total_interested_date_wise: get_time_slot_child_event_total_interested(params[:current_time_slot_dates], e),
          recent_activity: e.interest_levels.last(4).map { |i| {level: i.level, user: i.user.id }},
          passes_in_wallets: e.event.passes.map { |e| e.wallets }.size
          }
            
      end
    
      render json: {
        code: 200,
        success: true,
        message: 'Child_Event Stats',
        data: {
          stats: @event
        }
          }
    else
        render json: {
          code: 400,
          success: false,
          message: 'business_id and current_time_slot_dates are required.',
          data: nil
        }
      end #if
   # def total_events
end

  private

def get_redem_price(going)
  if going.offer_type == "Ticket"
    going.offer.ticket_purchases.price
  end
end

  def get_redemption_type(going)
      if going.offer_type == "Ticket"
        if going.offer.event.price_type == "free_ticketed_event"
          "Free Ticket"
        else
          "Paid Ticker"
        end    
      elsif going.offer_type == "Pass"
        if going.offer.pass_type == "vip"
          "VIP Gues Pass"
          else
            "Guest Pass"
          end
      end
  end

   def get_time_slot_child_total_going(current_time_slot_dates, event)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end


   # def get_time_slot_interestlevel_recent_activity(current_time_slot_dates, event)
   #  @total_views = []
   #  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
   #  current_dates_array.each do |date|
   #    p_date = Date.parse(date)
   #    @views = event.child_events.map { |e| e.interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)}.each do |activity|
   #      @total_views << {
          
   #      }
   #    end
   #    end #each
   #    @total_views
   # end

  #  def get_time_slot_parent_event_ticket(current_time_slot_dates, business)
  #   @total_views = []
  #   current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  #   current_dates_array.each do |date|
  #     p_date = Date.parse(date)
  #      if business.created_at == p_date.midnight..p_date.end_of_day
  #          @views = business.tickets.map { |e| e.quantity }
  #     end #each
        
  #     end
  #     @views
  # end


 def get_time_slot_child_total_views(current_time_slot_dates, event)
  @total_views = []
  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @views = event.views.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@views.blank?
      @total_views.push(@views.size)
    end
    end #each
    get_sum_of_array_elements(@total_views)
 end


 def get_time_slot_child_total_comments(current_time_slot_dates, event)
  @total_views = []
  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @views = event.comments.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@views.blank?
      @total_views.push(@views.size)
    end
    end #each
    get_sum_of_array_elements(@total_views)
 end

def get_time_slot_parent_event_total_interested(time_slot_dates, event)
 dates_array = time_slot_dates.split(',').map {|s| s.to_s }
 @time_slot_dates_stats = {}
 dates_array.each do |date|
  p_date = Date.parse(date)
  @time_slot_dates_stats[date.to_date] = event.child_events.map {|e| e.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size}.sum 

 end# each

 @time_slot_dates_stats
end

   def get_time_slot_child_event_total_going(time_slot_dates, event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_child_event_total_interested(time_slot_dates, event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_parent_event_total_going(time_slot_dates, event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = event.child_events.map {|e| e.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size}.sum 

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_user_event_followers(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.user.followers.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_user_event_ambassadors(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.user.ambassadors.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_parent_event_total_comments(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @comments = business.child_events.map { |e| e.comments }.map { |i| i.where(created_at: p_date.midnight..p_date.end_of_day)}.sum
      if !@comments.blank?
        @total_views.push(@comments.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_parent_total_views(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.child_events.map { |e| e.views }.map { |i| i.where(created_at: p_date.midnight..p_date.end_of_day) }.sum
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

  def get_time_slot_total_events(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.events.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

  def get_time_slot_total_passes(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.passes.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

  def get_time_slot_total_special_offers(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.special_offers.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

  def get_time_slot_total_competitions(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.competitions.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

  def get_time_slot_total_ambassadors(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.ambassadors.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
  end

   def get_time_slot_total_views(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.business_views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end


   def get_time_slot_views_date_wise(time_slot_dates, business)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = business.business_views.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_comments(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.comments.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_comments_date_wise(time_slot_dates, business)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = business.comments.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_followers(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.followers.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_followers_date_wise(time_slot_dates, business)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = business.followers.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_going(current_time_slot_dates, event)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_going_date_wise(time_slot_dates, event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_maybe(current_time_slot_dates, event)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_maybe_date_wise(time_slot_dates, event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def get_time_slot_total_shares(current_time_slot_dates, business)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = business.business_shares.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      get_sum_of_array_elements(@total_views)
   end

   def get_time_slot_shares_date_wise(time_slot_dates, business)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }
     @time_slot_dates_stats = {}
     dates_array.each do |date|
      p_date = Date.parse(date)
      @time_slot_dates_stats[date.to_date] = business.business_shares.where(created_at: p_date.midnight..p_date.end_of_day).size

     end# each

     @time_slot_dates_stats
   end

   def business
    business = request_user
   end

   def get_sum_of_array_elements(array)
    array.inject(0){|sum,x| sum + x }
  end


end
