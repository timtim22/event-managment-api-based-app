class Api::V1::AnalyticsController < Api::V1::ApiMasterController
  before_action :authorize_request

  def get_event_stats
    if !params[:event_id].blank? && !params[:frequency].blank? && !params[:date].blank?
          valid_frequencies = ['daily', 'weekly','overall']
          if !validate_frequency(params[:frequency], valid_frequencies)
              render json: {
                code: 400,
                success: true,
                message: "frequency is invalid, please select one from #{valid_frequencies.join("', '")}",
                data: nil
              }
              return
          end
           event = ChildEvent.find(params[:event_id])
              case params[:frequency]
              when "daily"
                start_date = params[:date]
                end_date = params[:date]
                before_start_date = Date.parse(params[:date]) - 1
                before_start_date_to_string = before_start_date.to_s
                before_end_date = Date.parse(params[:date]) - 1
                before_end_date_to_string = before_end_date.to_s
                @current_time_slot_dates = generate_date_range(start_date, end_date)
                @before_current_time_slot_dates = generate_date_range(before_start_date_to_string, before_end_date_to_string)
              when "weekly"
                start_date = Date.parse(params[:date]).tomorrow - 7.days
                start_date_to_string = start_date.to_s
                end_date = params[:date]
                @current_time_slot_dates = generate_date_range(start_date_to_string, end_date)
                before_start_date = Date.parse(params[:date]).tomorrow - 14.days
                before_start_date_to_string = before_start_date.to_s
                before_end_date = Date.parse(params[:date]).tomorrow - 7.days
                before_end_date_to_string = before_end_date.to_s
                @before_current_time_slot_dates = generate_date_range(before_start_date_to_string, before_end_date_to_string)
              when  "overall"
                 start_date = event.created_at.to_date.to_s
                 end_date = event.end_date.to_date.to_s
                 @current_time_slot_dates = generate_date_range(start_date, end_date)
                 # in case of overall there should be no comparison between time slots
                 @before_current_time_slot_dates = generate_date_range(start_date, end_date)

              else
                "Do nothing"
              end
              
              dates = []
              @current_time_slot_dates.each do |date|
                dt = {}
                data =  {
                    "impressions" => event.views.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
                    "attending_count" =>  event.going_interest_levels.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
                    "maybe_count" => event.interested_interest_levels.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
                    "passes_check_in_count" => event.event.passes.map{|p| p.redemptions.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size }.sum,
                    "shared_count" =>  event.event_shares.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size + event.event_forwardings.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size
                  }
                 dt[date.to_date.strftime("%a %d")] = data
                 dates << dt
              end #each

              stats = {
                "total_checked_in" => get_total_event_checked_in(event.event),
                "time_slot_total_checked_in" => get_time_slot_total_pass_checked_in(@current_time_slot_dates, event.event),
                "total_paid_checked_in" => get_total_paid_checked_in(event.event),
                "time_slot_total_paid_checked_in" => get_time_slot_event_paid_checked_in(@current_time_slot_dates, event.event),
                "total_pass_checked_in" => get_pass_total_checked_in(event.event),
                "time_slot_total_pass_checked_in" => get_time_slot_total_pass_checked_in(@current_time_slot_dates, event.event),
                "max_attendees" => event.event.max_attendees,
                "max_passes" => event.event.passes.size,
                "total_earning" => get_total_event_earning(event.event),
                "total_attendees" => event.going_interest_levels.size,
                "time_slot_total_attendees" => get_time_slot_total_attendees(@current_time_slot_dates, event),
                "time_slot_movement" => get_time_slot_movement_in_event_attendees(@current_time_slot_dates, @before_current_time_slot_dates, event),
                "demographics" => get_demographics(event),
                 "graph_stats" => {
                    "time_slot_total_impressions" => get_time_slot_total_views(@current_time_slot_dates, event),
                    "time_slot_attendees" => get_time_slot_total_attendees(@current_time_slot_dates, event),
                    "time_slot_total_interested_people" => get_time_slot_total_interested_people(@current_time_slot_dates, event),
                    "time_slot_total_pass_checked_in" => get_time_slot_total_pass_checked_in(@current_time_slot_dates, event.event),
                    "time_slot_total_shared_events" => get_time_slot_total_shared_events(@current_time_slot_dates, event),
                    "dates" =>  dates
                }
              }

              @event_stats = {
                  "event_id" => event.id,
                  "name" => event.name,
                  "start_date" => event.start_date,
                  "end_date" => event.end_date,
                  "start_time" => get_date_time(event.start_date, event.start_time),
                  "end_time" => get_date_time(event.end_date, event.end_time),
                  "location" => eval(event.location),
                  "event_type" => event.event_type,
                  "image" => event.image,
                  "price_type" => event.event.price_type,
                  "price" => event.event.price,
                  "additional_media" => event.event.event_attachments,
                  "created_at" => event.created_at,
                  "updated_at" => event.updated_at,
                  "stats" => stats,
                }
    
                render json: {
                  code: 200,
                  success: true,
                  message: '',
                  data: {
                    event: @event_stats
                  }
                }
                else
                  render json: {
                    code: 400,
                    success: true,
                    message: 'event_id, date and frequency are required.',
                    data: nil
                  }
                end
              end




  def get_offer_stats
    if !params[:offer_id].blank? && !params[:frequency].blank? && !params[:date].blank?
      valid_frequencies = ['daily', 'weekly','overall']
      if !validate_frequency(params[:frequency], valid_frequencies)
          render json: {
            code: 400,
            success: true,
            message: "frequency is invalid, please select one from #{valid_frequencies.join("', '")}",
            data: nil
          }
          return
      end

      offer = SpecialOffer.find(params[:offer_id])
      case params[:frequency]
      when "daily"
        start_date = params[:date]
        end_date = params[:date]
        before_start_date = Date.parse(params[:date]) - 1
        before_start_date_to_string = before_start_date.to_s
        before_end_date = Date.parse(params[:date]) - 1
        before_end_date_to_string = before_end_date.to_s
        @current_time_slot_dates = generate_date_range(start_date, end_date)
        @before_current_time_slot_dates = generate_date_range(before_start_date_to_string, before_end_date_to_string)
      when "weekly"
        start_date = Date.parse(params[:date]) - 6.days
        start_date_to_string = start_date.to_s
        end_date = params[:date]
        @current_time_slot_dates = generate_date_range(start_date_to_string, end_date)
        before_start_date = Date.parse(params[:date]) - 14.days
        before_start_date_to_string = before_start_date.to_s
        before_end_date = Date.parse(params[:date]) - 6.days
        before_end_date_to_string = before_end_date.to_s
        @before_current_time_slot_dates = generate_date_range(before_start_date_to_string, before_end_date_to_string)
      when  "overall"
          start_date = offer.created_at.to_date.to_s
          end_date = offer.validity.to_date.to_s
         @current_time_slot_dates = generate_date_range(start_date, end_date)
         # in case of overall there should be no comparison between time slots
         @before_current_time_slot_dates = generate_date_range(start_date, end_date)

      else
        "Do nothing"
      end


      dates = []
      @current_time_slot_dates.each do |date|
        dt = {}
        data =  {
          impression_count: offer.views.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
          in_wallet_count: offer.wallets.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
          redeemed_count: offer.redemptions.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
          shared_count: offer.offer_shares.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size + offer.offer_forwardings.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
          }
         dt[date.to_date.strftime("%a %d")] = data
         dates << dt
      end #each
      

      stats = {
        offer_start_date: offer.date.strftime(get_time_format),
        offer_creation_date: offer.created_at, 
        offer_end_date: offer.validity.strftime(get_time_format),
        max_redemptions: offer.quantity,
        total_redeem_count: offer.redemptions.size,
        movement_percentage: get_time_slot_increment_decrement_in_offer_views(@current_time_slot_dates, @before_current_time_slot_dates, offer),
        "demographics" => get_offer_demographics(offer),
        graph_stats: {
          total_impression_count: get_time_slot_total_offer_impresssions(offer, @current_time_slot_dates),
          total_in_wallet_count: get_time_slot_offer_in_wallet(@current_time_slot_dates, offer),
          total_redeemed_count: get_time_slot_total_redemptions(offer, @current_time_slot_dates),
          total_shared_count: get_time_slot_total_offer_shares(@current_time_slot_dates, offer),
          dates: dates
       }
      }

      render json: {
        code: 200,
        success: true,
        message: '',
        data: {
          stats: stats
        }
      }
    else
      render json: {
        code:400,
        success: false,
        message: 'offer_id, date and frequency are required.',
        data: nil
      }
    end
  end



  def get_competition_stats
    if !params[:competition_id].blank? && !params[:frequency].blank? && !params[:date].blank?
      valid_frequencies = ['daily', 'weekly','overall']
      if !validate_frequency(params[:frequency], valid_frequencies)
          render json: {
            code: 400,
            success: true,
            message: "frequency is invalid, please select one from #{valid_frequencies.join("', '")}",
            data: nil
          }
          return
      end

     
      competition = Competition.find(params[:competition_id])
      case params[:frequency]
      when "daily"
        start_date = params[:date]
        end_date = params[:date]
        before_start_date = Date.parse(params[:date]) - 1
        before_start_date_to_string = before_start_date.to_s
        before_end_date = Date.parse(params[:date]) - 1
        before_end_date_to_string = before_end_date.to_s
        @current_time_slot_dates = generate_date_range(start_date, end_date)
        @before_current_time_slot_dates = generate_date_range(before_start_date_to_string, before_end_date_to_string)
      when "weekly"
        start_date = Date.parse(params[:date]) - 6.days
        start_date_to_string = start_date.to_s
        end_date = params[:date]
        @current_time_slot_dates = generate_date_range(start_date_to_string, end_date)
        before_start_date = Date.parse(params[:date]) - 14.days
        before_start_date_to_string = before_start_date.to_s
        before_end_date = Date.parse(params[:date]) - 6.days
        before_end_date_to_string = before_end_date.to_s
        @before_current_time_slot_dates = generate_date_range(before_start_date_to_string, before_end_date_to_string)
      when  "overall"
          start_date = competition.created_at.to_date.to_s
          end_date = competition.end_date.to_date.to_s
         @current_time_slot_dates = generate_date_range(start_date, end_date)
         # in case of overall there should be no comparison between time slots
         @before_current_time_slot_dates = generate_date_range(start_date, end_date)

      else
        "Do nothing"
      end

      
      
      dates = []
      @current_time_slot_dates.each do |date|
        dt = {}
        data =  {
          impression_count: competition.views.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
          entries_count: competition.registrations.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
          shared_count: competition.offer_shares.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size + competition.offer_forwardings.where(created_at: Date.parse(date).midnight..Date.parse(date).end_of_day).size,
          }
         dt[date.to_date.strftime("%a %d")] = data
         dates << dt
      end #each


      stats = {
        competition_winners: competition.competition_winners.map {|c| {
            winner_name: User.get_full_name(c.user),
            winner_image: c.user.avatar,
            winner_id: c.user.id
        }},
        draw_date: competition.end_date,
        start_date: competition.start_date,
        creation_date: competition.created_at,
        end_date: competition.end_date,
        total_entries_count: competition.registrations.size,
        movement_percentage: get_time_slot_movement_in_competition_entries(@current_time_slot_dates, @before_current_time_slot_dates, competition),
        "demographics" =>  get_competition_demographics(competition),
        graph_stats: {
          total_impression_count: get_time_slot_total_competition_impresssions(competition, @current_time_slot_dates),
          total_entries_count: get_time_slot_total_entries(competition,@current_time_slot_dates),
          total_shared_count: get_time_slot_total_offer_shares(@current_time_slot_dates, competition),
          dates: dates
      }
    }

        render json: {
          code: 200,
          success: true,
          message: '',
          data: {
            stats: stats
          }
        }
      else
        render json: {
          code:400,
          success: false,
          message: 'competition_id, date and frequency are required.',
          data: nil
        }
      end
  end





  # def get_dashboard

  #  if !params[:business_id].blank? && !params[:resource].blank? && !params[:current_time_slot_dates].blank? && !params[:before_current_time_slot_dates].blank?

  #   @business = User.find(params[:business_id])
  #    resource = params[:resource]
  #    business_detail = []
  #    business_detail << {
  #      "total_events" =>  @business.events.size,
  #      "total_competitions" => @business.competitions.size,
  #      "total_offers" => @business.special_offers.size.to_i + @business.passes.size.to_i,
  #      "total_followers" => @business.followers.size,
  #      "business_name" => get_full_name(@business),
  #      "business_logo" => @business.avatar,
  #    }
  #   case resource
  #     when 'events'
  #       events = []
  #    @business.events.each do |event|
  #          stats = []
  #          stats << {
  #         "time_slot_total_attendees" => get_time_slot_total_attendees(params[:current_time_slot_dates], event),
  #         "time_slot_increment_decrement_in_attendees" => get_time_slot_increment_decrement_in_attendees(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
  #         "time_slot_attendees_date_wise" => get_time_slot_attendees_date_wise(params[:current_time_slot_dates], event),
  #         "time_slot_total_views" => get_time_slot_total_views(params[:current_time_slot_dates], event),
  #         "time_slot_increment_decrement_in_views" => get_time_slot_increment_decrement_in_views(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
  #         "time_slot_event_views_date_wise" => get_time_slot_event_views_date_wise(params[:current_time_slot_dates],event),
  #         "time_slot_total_sold_tickets" => get_time_slot_total_sold_tickets(params[:current_time_slot_dates], event),
  #         "time_slot_increment_decrement_in_sold_tickets" => time_slot_increment_decrement_in_sold_tickets(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
  #         "time_slot_sold_tickets_date_wise" => get_time_slot_sold_tickets_date_wise(params[:current_time_slot_dates] ,event),
  #         "time_slot_total_interested_people" => get_time_slot_total_interested_people(params[:current_time_slot_dates], event),
  #         "time_slot_interested_increment_decrement" => get_time_slot_interested_increment_decrement(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
  #         "time_slot_total_shared_events" => get_time_slot_total_shared_events(params[:current_time_slot_dates], event),
  #         "time_slot_increment_decrement_in_shared_events" => get_time_slot_increment_decrement_in_shared_events(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
  #         "time_slot_shares_date_wise" => get_time_slot_shares_date_wise(params[:current_time_slot_dates],event),
  #         "time_slot_total_event_comments" => get_time_slot_total_event_comments(params[:current_time_slot_dates], event),
  #         "time_slot_increment_decrement_in_event_comments" => get_time_slot_increment_decrement_in_event_comments(params[:current_time_slot_dates], params[:before_current_time_slot_dates], event),
  #         "time_slot_comments_date_wise" => get_time_slot_comments_date_wise(params[:current_time_slot_dates],event)
  #       }

  #         if event.location.include? "\"=>\""
  #             location =  eval(event.location)["city"] + ", " + eval(event.location)["country"]
  #         else
  #               location = event.location
  #         end  

  #       events << {
  #         "event_id" => event.id,
  #         "name" => event.name,
  #         "start_date" => event.start_date,
  #         "end_date" => event.end_date,
  #         "start_time" => event.start_time,
  #         "end_time" => event.end_time,
  #         "location" => location,
  #         # "location" => eval(event.location)["city"] + ", " + eval(event.location)["country"],
  #         # "lat" => eval(event.location)["geometry"]["lat"],
  #         # "lng" => eval(event.location)["geometry"]["lng"],
  #         "event_type" => event.event_type,
  #         "image" => event.image,
  #         "price_type" => event.price_type,
  #         "price" => event.price,
  #         "additional_media" => event.event_attachments,
  #         "created_at" => event.created_at,
  #         "updated_at" => event.updated_at,
  #         "stats" => stats
  #       }
  #       end #each
  #       render json: {
  #         code: 200,
  #         success: true,
  #         message: '',
  #         data: {
  #           business_detail: business_detail,
  #           resource: events
  #         }
  #       }
  #     when 'offers'
  #       special_offers = []
  #        @business.special_offers.each do |offer|
  #         stats = []
  #         stats << {
  #          "time_slot_total_special_offers" => get_time_slot_total_special_offers(params[:current_time_slot_dates], offer),
  #          "time_slot_increment_decrement_in_special_offers" =>  get_time_slot_special_offers_increment_decrement(params[:current_time_slot_dates],    params[:before_current_time_slot_dates], offer),
  #          "time_slot_taken_special_offers_date_wise" => get_time_slot_special_offers_date_wise(params[:current_time_slot_dates], offer),
  #          "time_slot_offer_views" => get_time_slot_offer_views(params[:current_time_slot_dates], offer),
  #          "time_slot_increment_decrement_in_offer_views" => get_time_slot_increment_decrement_in_offer_views(params[:current_time_slot_dates], params[:before_current_time_slot_dates], offer),
  #          "time_slot_views_date_wise" => get_time_slot_views_date_wise(params[:current_time_slot_dates], offer),
  #          "time_slot_increment_decrement_in_offer_redemptions" => get_time_slot_increment_decrement_in_offer_redemptions(params[:current_time_slot_dates], params[:before_current_time_slot_dates], offer),
  #          "time_slot_redemptions_date_wise" => get_time_slot_redemptions_date_wise(params[:current_time_slot_dates], offer),
  #          "time_slot_total_offer_shares" => get_time_slot_total_offer_shares(params[:current_time_slot_dates], offer),
  #          "time_slot_increment_decrement_in_offer_shares" => get_time_slot_increment_decrement_in_offer_shares(params[:current_time_slot_dates], params[:before_current_time_slot_dates], offer),
  #          "time_slot_offer_shares_date_wise" => get_time_slot_offer_shares_date_wise(params[:current_time_slot_dates], offer),
  #          "time_slot_total_ambassador_offer_shares" =>  get_time_slot_total_ambassador_offer_shares(params[:current_time_slot_dates], offer),
  #          "time_slot_increment_decrement_in_ambassador_offer_shares" => get_time_slot_increment_decrement_in_ambassador_offer_shares(params[:current_time_slot_dates], params[:before_current_time_slot_dates], offer),
  #          "time_slot_ambassador_offer_shares_date_wise" => get_time_slot_ambassador_offer_shares_date_wise(params[:current_time_slot_dates], offer)

  #         }
  #         special_offers << {
  #         id: offer.id,
  #         title: offer.title,
  #         sub_title: offer.sub_title,
  #         location: offer.location,
  #         date: offer.date,
  #         time: offer.time,
  #         lat: offer.lat,
  #         lng: offer.lng,
  #         image: offer.image.url,
  #         creator_name: offer.user.business_profile.profile_name,
  #         creator_image: offer.user.avatar,
  #         description: offer.description,
  #         validity: offer.validity,
  #         grabbers_count: offer.wallets.size,
  #         stats: stats
  #       }
  #       end #each

  #       render json: {
  #         code: 200,
  #         success: true,
  #         message: '',
  #         data: {
  #           business_detail: business_detail,
  #           resource: special_offers
  #         }
  #       }

  #     when 'competitions'
  #       competitions = []
  #       @business.competitions.each do |competition|
  #         stats = []
  #          stats << {
  #            "time_slot_total_competitions" =>  get_time_slot_total_competitions(params[:current_time_slot_dates], competition),
  #            "time_slot_competitions_increment_decrement" => get_time_slot_competitions_increment_decrement(params[:current_time_slot_dates],    params[:before_current_time_slot_dates], competition),
  #            "time_slot_competitions_date_wise" => get_time_slot_competitions_date_wise(params[:current_time_slot_dates], competition)
  #          }
  #         competitions << {
  #           id: competition.id,
  #           title: competition.title,
  #           description: competition.description,
  #           location: competition.location,
  #           start_date: competition.start_date,
  #           end_date: competition.end_date,
  #           start_time: competition.start_time,
  #           end_time: competition.end_time,
  #           price: competition.price,
  #           lat: competition.lat,
  #           lng: competition.lng,
  #           image: competition.image.url,
  #           friends_participants_count: competition.registrations.map {|reg| if(request_user.friends.include? reg.user) then reg.user end }.size,
  #           creator_name: competition.user.first_name + " " + competition.user.last_name,
  #           creator_image: competition.user.avatar,
  #           validity: competition.validity + "T" + competition.validity_time.strftime("%H:%M:%S") + ".000Z",
  #           stats: stats
  #         }
  #       end #each

  #       render json: {
  #         code: 200,
  #         success: true,
  #         message: '',
  #         data: {
  #           business_detail: business_detail,
  #           resource: competitions
  #         }
  #       }

  #     when 'passes'
  #     passes = []
  #     @business.passes.each do |pass|
  #       stats = []
  #       stats << {
  #         "time_slot_total_special_offers" => get_time_slot_total_passes(params[:current_time_slot_dates], pass),
  #         "time_slot_passes_increment_decrement" =>  get_time_slot_passes_increment_decrement(params[:current_time_slot_dates], params[:before_current_time_slot_dates], pass),
  #         "time_slot_passes_date_wise" => get_time_slot_passes_date_wise(params[:current_time_slot_dates], pass)
  #       }
  #       passes << {
  #         id: pass.id,
  #         title: pass.title,
  #         host_name: pass.event.user.first_name + " " + pass.event.user.last_name,
  #         host_image: pass.event.user.avatar,
  #         event_name: pass.event.name,
  #         event_id: pass.event.id,
  #         event_image: pass.event.image,
  #         event_location: pass.event.location,
  #         event_start_time: pass.event.start_time,
  #         event_end_time: pass.event.end_time,
  #         event_date: pass.event.start_date,
  #         distributed_by: distributed_by(pass),
  #         validity: pass.validity + " " + pass.validity_time.strftime("%H:%M:%S").to_s,
  #         grabbers_count: pass.wallets.size,
  #         stats: stats
  #       }
  #         end#each

  #         render json: {
  #           code: 200,
  #           success: true,
  #           message: '',
  #           data: {
  #             business_detail: business_detail,
  #             resource: passes
  #           }
  #         }

  #     else
  #       #do nothing
  #     end #case end
  #   else
  #     render json: {
  #       code: 400,
  #       success: false,
  #       message: 'business_id, current_time_slot_dates,before_current_time_slot_dates and resource are required fields.',
  #       data: nil
  #     }
  #   end #if

  # end

  private

  ##################### attendess #######################

 def get_date_time(date, time)
    d = date.strftime("%Y-%m-%d")
    t = time.strftime("%H:%M:%S")
    datetime = d + "T" + t + ".000Z"
 end


   def get_time_slot_total_attendees(current_time_slot_dates, event)
    dates_array = get_dates_array(current_time_slot_dates) 
    event.going_interest_levels.where(created_at: dates_array).size
   end




   def get_time_slot_increment_decrement_in_attendees(time_slot_dates, before_current_time_slot_dates, event)

      @current_time_slot_registrations = []
      @before_current_time_slot_registrations = []
      @increment_decreament_in_registrations = {}

      current_dates_array = time_slot_dates.split(',').map {|s| s.to_s }
      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @attendees = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@attendees.blank?
          @current_time_slot_registrations.push(@attendees.size)
        end
        end #each

        before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
        before_current_dates_array.each do |date|
          p_date = Date.parse(date)
          @attendees = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@attendees.blank?
            @before_current_time_slot_registrations.push(@attendees.size)
          end
          end #each

       @current_registrations = get_sum_of_array_elements(@current_time_slot_registrations)
       @before_registrations = get_sum_of_array_elements(@before_current_time_slot_registrations)
       @diff = @current_registrations - @before_registrations

       @increment_decreament_in_registrations['before_registrations'] = @before_registrations
       @increment_decreament_in_registrations['current_registrations'] = @current_registrations
       @increment_decreament_in_registrations['difference'] = @diff

       @increment_decreament_in_registrations

   end

   def get_time_slot_attendees_date_wise(time_slot_dates,event)
     dates_array = time_slot_dates.split(',').map {|s| s.to_s }

     @time_slot_dates_stats = []

     dates_array.each do |date|
      date_hash = {}
      p_date = Date.parse(date)
      date_hash[date] = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size
      @time_slot_dates_stats.push(date_hash)
     end# each

     @time_slot_dates_stats
   end

   ########################## views ##############################

   def get_time_slot_total_views(current_time_slot_dates, event)
     dates_array = get_dates_array(current_time_slot_dates) 
     event.views.where(created_at: dates_array).size
   end





   def get_time_slot_increment_decrement_in_views(current_time_slot_dates, before_current_time_slot_dates, event)

    @current_time_slot_views = []
    @before_current_time_slot_views = []

    @increment_decreament_in_views = {}

    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = event.views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @current_time_slot_views.push(@views.size)
      end
      end #each
      before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
      before_current_dates_array.each do |date|
        p_date = Date.parse(date)
        @views = event.views.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@views.blank?
          @before_current_time_slot_views.push(@views.size)
        end
        end #each

     @current_views = get_sum_of_array_elements(@current_time_slot_views)
     @before_views = get_sum_of_array_elements(@before_current_time_slot_views)

     @increment_decreament_in_views['before_views'] = @before_views
     @increment_decreament_in_views['current_views'] = @current_views
     @increment_decreament_in_views['difference'] = @current_views - @before_views
     @increment_decreament_in_views
 end



 def get_time_slot_event_views_date_wise(time_slot_dates,event)
   dates_array = time_slot_dates.split(',').map {|s| s.to_s }
   @time_slot_dates_stats = []
   dates_array.each do |date|
    date_hash = {}
    p_date = Date.parse(date)
    date_hash[date] = event.views.where(created_at: p_date.midnight..p_date.end_of_day).size
   @time_slot_dates_stats.push(date_hash)
   end# each

   @time_slot_dates_stats
 end

 def get_time_slot_interested_people_date_wise(time_slot_dates,event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = []
  dates_array.each do |date|
    date_hash = {}
   p_date = Date.parse(date)
   date_hash[date] = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size
   @time_slot_dates_stats.push(date_hash)
  end# each

  @time_slot_dates_stats
end



   ########################### tickets ###################################
    def get_time_slot_total_sold_tickets(current_time_slot_dates, event)
      @tickets_sold = 0
      current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
     if !event.ticket.blank?
      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @tickets = TicketPurchase.where(ticket_id: event.ticket.id).where(created_at: p_date.midnight..p_date.end_of_day)

        if !@tickets.blank?
          @tickets.each do |ticket|
            @tickets_sold = @tickets_sold + ticket.quantity.to_i
          end
        end
        end #each
      end #if
        @tickets_sold
     end


   def time_slot_increment_decrement_in_sold_tickets(current_time_slot_dates, before_current_time_slot_dates, event)

      @current_tickets_sold = 0
      @before_tickets_sold = 0

      @increment_decrement_in_sold_tickets = {}

      current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
     if !event.ticket.blank?
      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @tickets = TicketPurchase.where(ticket_id: event.ticket.id).where(created_at: p_date.midnight..p_date.end_of_day)

        if !@tickets.blank?
          @tickets.each do |ticket|
            @current_tickets_sold = @current_tickets_sold + ticket.quantity.to_i
          end
        end
        end #each

        before_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
        before_dates_array.each do |date|
          p_date = Date.parse(date)
          @tickets = TicketPurchase.where(ticket_id: event.ticket.id).where(created_at: p_date.midnight..p_date.end_of_day)

          if !@tickets.blank?
            @tickets.each do |ticket|
              @before_tickets_sold = @before_tickets_sold + ticket.quantity.to_i
            end
          end
          end #each

      end #if
        @increment_decrement_in_sold_tickets['before_sold_tickets'] = @before_tickets_sold
        @increment_decrement_in_sold_tickets['current_sold_tickets'] = @current_tickets_sold
        @increment_decrement_in_sold_tickets['difference'] = @current_tickets_sold - @before_tickets_sold

        @increment_decrement_in_sold_tickets
     end

     def get_time_slot_sold_tickets_date_wise(time_slot_dates,event)
      dates_array = time_slot_dates.split(',').map {|s| s.to_s }
      @time_slot_dates_stats = {}
      if !event.ticket.blank?
        dates_array.each do |date|
          p_date = Date.parse(date)
          @ticket_purchases = TicketPurchase.where(ticket_id: event.ticket.id).where(created_at: p_date.midnight..p_date.end_of_day)
          if !@ticket_purchases.blank?
            @ticket_purchases.each do |p|
              time_slot_days.push(p.quantity)
            end
          end
          end #each
        end #if

        get_sum_of_array_elements(@time_slot_dates_stats)
    end

  ################################## interested #####################################

  def get_time_slot_total_interested_people(current_time_slot_dates, event)
    dates_array = get_dates_array(current_time_slot_dates) 
    @interested = event.interested_interest_levels.where(created_at: dates_array).size
  end





  def get_time_slot_interested_increment_decrement(current_time_slot_dates, before_current_time_slot_dates, event)
    @current_time_slot_interested = []
    @before_current_time_slot_interested = []

    @increment_decreament_in_interested = {}

    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @interested = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@interested.blank?
        @current_time_slot_interested.push(@interested.size)
      end
      end #each
      before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
      before_current_dates_array.each do |date|
        p_date = Date.parse(date)
        @interested = event.going_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@interested.blank?
          @before_current_time_slot_interested.push(@interested.size)
        end
        end #each

     @current_interested = get_sum_of_array_elements(@current_time_slot_interested)
     @before_interested = get_sum_of_array_elements(@before_current_time_slot_interested)
     @diff = @current_interested - @before_interested

     @increment_decreament_in_interested['before_interested'] = @before_interested
     @increment_decreament_in_interested['current_interested'] = @current_interested
     @increment_decreament_in_interested['difference'] = @diff
     @increment_decreament_in_interested

 end

 def get_time_slot_interested_date_wise(time_slot_dates,event)
   dates_array = time_slot_dates.split(',').map {|s| s.to_s }

   @time_slot_dates = {}
   dates_array.each do |date|
    p_date = Date.parse(date)
    @time_slot_dates[date.to_date] = event.interested_interest_levels.where(created_at: p_date.midnight..p_date.end_of_day).size
   end# each

   @time_slot_dates
 end

################################## Special offers #####################################

 def get_time_slot_total_special_offers(current_time_slot_dates, offer)
  @taken = []
  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @taken_offers = offer.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@taken_offers.blank?
      @taken.push(@taken_offers.size)
    end
    end #each
    get_sum_of_array_elements(@taken)
end

def get_time_slot_special_offers_increment_decrement(current_time_slot_dates,    before_current_time_slot_dates, offer)

  @current_time_slot_special_offers = []
  @before_current_time_slot_special_offers = []

  @increment_decreament_in_special_offers = {}

  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }

  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @wallet = offer.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@wallet.blank?
      @current_time_slot_special_offers.push(@wallet)
    end
    end #each

    before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
    before_current_dates_array.each do |date|
      p_date = Date.parse(date)
      @wallet = offer.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@wallet.blank?
        @before_current_time_slot_special_offers.push(@wallet)
      end
      end #each

   @current_special_offers = @current_time_slot_special_offers.size
   @before_special_offers = @before_current_time_slot_special_offers.size
   @diff = @current_special_offers - @before_special_offers

   @increment_decreament_in_special_offers['before_special_offers'] = @before_special_offers
   @increment_decreament_in_special_offers['current_special_offers'] = @current_special_offers
   @increment_decreament_in_special_offers['difference'] = @diff

   @increment_decreament_in_special_offers
    end

    def get_time_slot_special_offers_date_wise(time_slot_dates, offer)
      dates_array = time_slot_dates.split(',').map {|s| s.to_s }
      @time_slot_dates = {}
      dates_array.each do |date|
       p_date = Date.parse(date)
       @time_slot_dates[date.to_date] = offer.wallets.where(created_at: p_date.midnight..p_date.end_of_day).size
      end# each

      @time_slot_dates
    end

   #################################### Passes #####################################

    def get_time_slot_total_passes(current_time_slot_dates, pass)
      @taken = []
      current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @taken_passes = pass.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@taken_passes.blank?
          @taken.push(@taken_passes.size)
        end
        end #each
      get_sum_of_array_elements(@taken)
    end

    def get_time_slot_passes_increment_decrement(current_time_slot_dates,    before_current_time_slot_dates, pass)

      @current_time_slot_passes = []
      @before_current_time_slot_passes = []

      @increment_decreament_in_passes = {}

      current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }

      current_dates_array.each do |date|
        p_date = Date.parse(date)
        @wallets = pass.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@wallets.blank?
          @current_time_slot_passes.push(@wallets.size)
        end
        end #each

        before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
        before_current_dates_array.each do |date|
          p_date = Date.parse(date)
          @wallets = pass.wallets.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@wallets.blank?
            @before_current_time_slot_passes.push(@wallets.size)
          end
          end #each

       @current_passes = get_sum_of_array_elements(@current_time_slot_passes)
       @before_passes = get_sum_of_array_elements(@before_current_time_slot_passes)
       @diff = @current_passes - @before_passes

       @increment_decreament_in_passes['before_passes'] = @before_passes
       @increment_decreament_in_passes['current_passes'] = @current_passes
       @increment_decreament_in_passes['difference'] = @diff

       @increment_decreament_in_passes
    end

    def get_time_slot_passes_date_wise(time_slot_dates, pass)
      dates_array = time_slot_dates.split(',').map {|s| s.to_s }

      @time_slot_dates_stats = {}
      dates_array.each do |date|
       p_date = Date.parse(date)
       @time_slot_dates_stats[date.to_date] = pass.wallets.where(created_at: p_date.midnight..p_date.end_of_day).size
      end# each

      @time_slot_dates_stats
    end

      #################################### Competitions #####################################

      def get_time_slot_total_competitions(current_time_slot_dates, competition)
          @taken = []
          current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
          current_dates_array.each do |date|
          p_date = Date.parse(date)
          @competitions = competition.registrations.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@competitions.blank?
            @taken.push(@competitions.size)
          end
          end #each
          get_sum_of_array_elements(@taken)
      end




      def get_time_slot_movement_in_competition_entries(current_time_slot_dates,    before_current_time_slot_dates, competition)
        current_dates_array = get_dates_array(current_time_slot_dates)
        before_dates_array = get_dates_array(before_current_time_slot_dates)
    
        current_size = 0
        before_size = 0

      
        current_size += competition.registrations.where(created_at: current_dates_array).size
        before_size += competition.registrations.where(created_at: before_dates_array).size
        difference = before_size - current_size
      
        movement_percent_before = get_percent_of(before_size, competition.registrations.size)
        movement_percent_now =   get_percent_of(current_size, competition.registrations.size)
    
        differenct_in_movement_percent =  movement_percent_now - movement_percent_before 
        differenct_in_movement_percent.round(2)
        #later to remove requirements not clear
        movement = 0

     
      end




      def get_time_slot_competitions_date_wise(time_slot_dates, competition)
        dates_array = time_slot_dates.split(',').map {|s| s.to_s }

        @time_slot_dates_stats = {}
        dates_array.each do |date|
         p_date = Date.parse(date)
         @time_slot_dates_stats[date.to_date] = competition.registrations.where(created_at: p_date.midnight..p_date.end_of_day).size
        end# each

        @time_slot_dates_stats
      end

   #################################### event sharing #####################################
      def get_time_slot_total_shared_events(current_time_slot_dates, event)
          dates_array = get_dates_array(current_time_slot_dates)
          @forwarding = event.event_forwardings.where(created_at: dates_array).size
          @shares = event.event_shares.where(created_at: dates_array).size
          total = @forwarding + @shares
     end



      def get_time_slot_increment_decrement_in_shared_events(current_time_slot_dates, before_current_time_slot_dates, event)

        @current_time_slot_shared_events = []
        @before_current_time_slot_shared_events = []

        @increment_decreament_in_shared_events = {}

        current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
        current_dates_array.each do |date|
          p_date = Date.parse(date)
          @shares = event.event_shares.where(created_at: p_date.midnight..p_date.end_of_day)
          if !@shares.blank?
            @current_time_slot_shared_events.push(@shares.size)
          end
          end #each
          before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
          before_current_dates_array.each do |date|
            p_date = Date.parse(date)
            @shares = event.event_shares.where(created_at: p_date.midnight..p_date.end_of_day)
            if !@shares.blank?
              @before_current_time_slot_shared_events.push(@shares.size)
            end
            end #each

         @current_shares = get_sum_of_array_elements(@current_time_slot_shared_events)
         @before_shares = get_sum_of_array_elements(@before_current_time_slot_shared_events)

         @increment_decreament_in_shared_events['before_shares'] = @before_shares
         @increment_decreament_in_shared_events['current_shares'] = @current_shares
         @increment_decreament_in_shared_events['difference'] = @current_shares - @before_shares
         @increment_decreament_in_shared_events
     end


     def get_time_slot_shares_date_wise(time_slot_dates,event)
      dates_array = time_slot_dates.split(',').map {|s| s.to_s }
      @time_slot_dates_stats = []
      dates_array.each do |date|
        date_hash = {}
       p_date = Date.parse(date)
       date_hash[date.to_date] = event.event_shares.where(created_at: p_date.midnight..p_date.end_of_day).size
       @time_slot_dates_stats.push(date_hash)
      end# each
      
      @time_slot_dates_stats
    end

  #################################### event chats #####################################

  def get_time_slot_total_event_comments(current_time_slot_dates, event)
    @total_comments = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @comments = event.comments.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@comments.blank?
        @total_comments.push(@comments.size)
      end
      end #each
      get_sum_of_array_elements(@total_comments)
  end



  def get_time_slot_increment_decrement_in_event_comments(current_time_slot_dates, before_current_time_slot_dates, event)

    @current_time_slot_event_comments = []
    @before_current_time_slot_event_comments = []

    @increment_decreament_in_event_comments = {}

    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @comments = event.comments.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@comments.blank?
          @current_time_slot_event_comments.push(@comments.size)
      end
      end #each
      before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
      before_current_dates_array.each do |date|
        p_date = Date.parse(date)
        @comments = event.comments.where(created_at: p_date.midnight..p_date.end_of_day)
        if !@comments.blank?
          @before_current_time_slot_event_comments.push(@comments.size)
        end
        end #each

     @current_comments = get_sum_of_array_elements(@current_time_slot_event_comments)
     @before_comments = get_sum_of_array_elements(@before_current_time_slot_event_comments)

     @increment_decreament_in_event_comments['before_comments'] = @before_comments
     @increment_decreament_in_event_comments['current_comments'] = @current_comments
     @increment_decreament_in_event_comments['difference'] = @current_comments - @before_comments
     @increment_decreament_in_event_comments
 end


 def get_time_slot_comments_date_wise(time_slot_dates,event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
    @time_slot_dates_stats[date.to_date] = event.comments.where(created_at: p_date.midnight..p_date.end_of_day).size

  end# each
  @time_slot_dates_stats
end

  #################################### offer stats new #####################################

  def get_time_slot_offer_views(current_time_slot_dates, offer)
    @total_views = []
    current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
    current_dates_array.each do |date|
      p_date = Date.parse(date)
      @views = offer.views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@views.blank?
        @total_views.push(@views.size)
      end
      end #each
      @time_slot_views = get_sum_of_array_elements(@total_views)
   end



   def get_time_slot_increment_decrement_in_offer_views(current_time_slot_dates, before_current_time_slot_dates, offer)

    current_dates_array = get_dates_array(current_time_slot_dates)
    before_dates_array = get_dates_array(before_current_time_slot_dates)

    current_size = 0
    before_size = 0
    movement_percent = 0
  
    current_size += offer.views.where(created_at: current_dates_array).size
    before_size += offer.views.where(created_at: before_dates_array).size
    difference = before_size - current_size
  
    if difference != 0
      movement_percent = get_percent_of(difference, before_size)
    end

      movement_percent   
 end

 def get_time_slot_views_date_wise(time_slot_dates, offer)
   dates_array = time_slot_dates.split(',').map {|s| s.to_s }
   @time_slot_dates_stats = {}
   dates_array.each do |date|
    p_date = Date.parse(date)
    @time_slot_dates_stats[date.to_date] = offer.views.where(created_at: p_date.midnight..p_date.end_of_day).size
   end# each

   @time_slot_dates_stats
 end


 def get_time_slot_total_offer_redemptions(current_time_slot_dates, offer)
  @total_redemptions = []
  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @redemptions = offer.redemptions.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@redemptions.blank?
      @total_redemptions.push(@redemptions)
    end
    end #each
     get_sum_of_array_elements(@redemptions)
 end


 def get_time_slot_increment_decrement_in_offer_redemptions(current_time_slot_dates, before_current_time_slot_dates, offer)

  @current_time_slot_redemptions = []
  @before_current_time_slot_redemptions = []

  @increment_decreament_in_redemptions = {}

  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @redemptions = offer.views.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@redemptions.blank?
      @current_time_slot_redemptions.push(@redemptions.size)
    end
    end #each
    before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
    before_current_dates_array.each do |date|
      p_date = Date.parse(date)
      @redemptions = offer.views.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@redemptions.blank?
        @before_current_time_slot_redemptions.push(@redemptions.size)
      end
      end #each

   @current_redemptions = get_sum_of_array_elements(@current_time_slot_redemptions)
   @before_redemptions = get_sum_of_array_elements(@before_current_time_slot_redemptions)

   @increment_decreament_in_redemptions['before_redemptions'] = @before_redemptions
   @increment_decreament_in_redemptions['current_redemptions'] = @current_redemptions
   @increment_decreament_in_redemptions['difference'] = @current_redemptions - @before_redemptions
   @increment_decreament_in_redemptions
end

def get_time_slot_redemptions_date_wise(time_slot_dates, offer)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
   @time_slot_dates_stats[date.to_date] = offer.redemptions.where(created_at: p_date.midnight..p_date.end_of_day).size

  end# each

  @time_slot_dates_stats
end


def get_time_slot_total_offer_shares(current_time_slot_dates, offer)
    dates_array = get_dates_array(current_time_slot_dates)
     @forwarding = offer.offer_forwardings.where(created_at: dates_array).size
     @shares = offer.offer_shares.where(created_at: dates_array).size
    total = @forwarding + @shares
 end


 def get_time_slot_increment_decrement_in_offer_shares(current_time_slot_dates, before_current_time_slot_dates, offer)

  @current_time_slot_shares = []
  @before_current_time_slot_shares = []

  @increment_decreament_in_shares = {}

  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day)
    if !@shares.blank?
      @current_time_slot_shares.push(@shares.size)
    end
    end #each
    before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
    before_current_dates_array.each do |date|
      p_date = Date.parse(date)
      @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day)
      if !@shares.blank?
        @before_current_time_slot_shares.push(@shares.size)
      end
      end #each

   @current_shares = get_sum_of_array_elements(@current_time_slot_shares)
   @before_shares = get_sum_of_array_elements(@before_current_time_slot_shares)

   @increment_decreament_in_shares['before_shares'] = @before_shares
   @increment_decreament_in_shares['current_shares'] = @current_shares
   @increment_decreament_in_shares['difference'] = @current_shares - @before_shares
   @increment_decreament_in_shares
end


def get_time_slot_offer_shares_date_wise(time_slot_dates, offer)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
   @time_slot_dates_stats[date.to_date] = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).size
  end# each

  @time_slot_dates_stats
end


def get_time_slot_total_ambassador_offer_shares(current_time_slot_dates, offer)
  @ambassador_shares = []
  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).where(is_ambassador: true)
    if !@shares.blank?
     @ambassador_shares.push(@shares.size)
    end
    end #each
     get_sum_of_array_elements(@ambassador_shares)
 end


 def get_time_slot_increment_decrement_in_ambassador_offer_shares(current_time_slot_dates, before_current_time_slot_dates, offer)

  @current_time_slot_shares = []
  @before_current_time_slot_shares = []

  @increment_decreament_in_shares = {}

  current_dates_array = current_time_slot_dates.split(',').map {|s| s.to_s }
  current_dates_array.each do |date|
    p_date = Date.parse(date)
    @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).where(is_ambassador: true)
    if !@shares.blank?
      @current_time_slot_shares.push(@shares.size)
     end #if !blank?
    end #each
    before_current_dates_array = before_current_time_slot_dates.split(',').map {|s| s.to_s }
    before_current_dates_array.each do |date|
      p_date = Date.parse(date)
      @shares = offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).where(is_ambassador: true)
      if !@shares.blank?
           @before_current_time_slot_shares.push(@shares.size)
      end #if !blank?
      end #each

   @current_shares = get_sum_of_array_elements(@current_time_slot_shares)
   @before_shares = get_sum_of_array_elements(@before_current_time_slot_shares)

   @increment_decreament_in_shares['before_shares'] = @before_shares
   @increment_decreament_in_shares['current_shares'] = @current_shares
   @increment_decreament_in_shares['difference'] = @current_shares - @before_shares
   @increment_decreament_in_shares
end


def get_time_slot_ambassador_offer_shares_date_wise(time_slot_dates, offer)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates_stats = {}
  dates_array.each do |date|
   p_date = Date.parse(date)

    @time_slot_dates_stats[date.to_date] =  offer.offer_shares.where(created_at: p_date.midnight..p_date.end_of_day).where(is_ambassador: true).size

  end# each

  @time_slot_dates_stats
end


def get_sum_of_array_elements(array)
  array.inject(0){|sum,x| sum + x }
end

##################################### New stats functions ##########################33

def get_time_slot_total_redemptions(special_offer, time_slot)
 dates_array = get_dates_array(time_slot)     
 special_offer.redemptions.where(created_at: dates_array).size  
end


def get_time_slot_total_offer_impresssions(special_offer, time_slot)
     dates_array = get_dates_array(time_slot)
     view = special_offer.views.where(created_at: dates_array).size
end


def get_time_slot_total_entries(competition, time_slot)
  dates_array = get_dates_array(time_slot)
  competition.registrations.where(created_at: dates_array).size  
end


def get_time_slot_total_competition_impresssions(competition, time_slot)
  dates_array = get_dates_array(time_slot)
  competition.views.where(created_at: dates_array).size
   
end


def get_time_slot_entries_date_wise(time_slot_dates,competition)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates = {}
  dates_array.each do |date|
   p_date = Date.parse(date)
   @time_slot_dates[date.to_date] = competition.registrations.where(created_at: p_date.midnight..p_date.end_of_day).size
  end# each

  @time_slot_dates
end

def get_event_paid_checked_in_date_wise(time_slot_dates,event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @time_slot_dates = []
  dates_array.each do |date|
    date_hash = {}
   p_date = Date.parse(date)
   date_hash[date.to_date] =  event.tickets.where(ticket_type: 'buy').map {|t| t.redemptions.where(created_at: p_date.midnight..p_date.end_of_day).size }.sum
   @time_slot_dates.push(date_hash)
  end# each
  @time_slot_dates
end


def get_event_pass_checked_in_date_wise(time_slot_dates,event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }

  @time_slot_dates = []
  dates_array.each do |date|
    date_hash = {}
   p_date = Date.parse(date)
   date_hash[date.to_date] =  event.passes.where(created_at: p_date.midnight..p_date.end_of_day).map {|p| p.redemptions.size }.sum
   @time_slot_dates.push(date_hash)
  end# each

  @time_slot_dates
end


def get_pass_total_checked_in(event)
  event.passes.map {|p| p.redemptions.size }.sum
end


def get_total_paid_checked_in(event)
  event.tickets.where(ticket_type: 'buy').map {|t| t.redemptions.size }.sum
end



def get_time_slot_total_paid_checked_in(time_slot_dates, event)
  dates_array = time_slot_dates.split(',').map {|s| s.to_s }
  @checked_in = []
  dates_array.each do |date|
     p_date = Date.parse(date)
     checked_in = event.tickets.map{|t| t.redemptions.where(created_at: p_date.midnight..p_date.end_of_day).size }.sum
     if !checked_in.blank?
       @checked_in.push(checked_in)
  end #if !blank?
  end #each
  @checked_in.size
end



def get_total_event_earning(event)
  @total_amount = 0
  event.tickets.map {|ticket| ticket.ticket_purchases.map {|p| @total_amount += p.price.to_i } }
  @total_amount.round(2)
end

def get_total_event_checked_in(event)
  total_checked_in = 0
  pass_checked_in = event.passes.map {|pass| total_checked_in += pass.redemptions.size }.sum
  ticket_checked_in = event.tickets.map {|ticket| total_checked_in += ticket.redemptions.size }.sum
  total_checked_in
end


def get_event_pass_checked_in(event)
pass_checked_in = 0
event.passes.map {|pass| pass_checked_in += pass.redemptions.size }
pass_checked_in
end

def get_time_slot_total_pass_checked_in(time_slot_dates, event)
     dates_array = get_dates_array(time_slot_dates)
     checked_in = event.passes.map{|p| p.redemptions.where(created_at: dates_array).size }.sum
end


def get_event_paid_checked_in(event)
 paid_checked_in = 0
 event.tickets.map {|ticket| paid_checked_in += ticket.redemptions.size }
 paid_checked_in
end


def validate_frequency(frequency,valid_frequencies)
  valid_frequencies.include? params[:frequency] 
end

def get_time_slot_offer_in_wallet(time_slot_dates, offer)
     dates_array = get_dates_array(time_slot_dates)
     in_wallet = offer.wallets.where(created_at: dates_array).size
end


def get_time_slot_event_paid_checked_in(time_slot_dates, event)
      dates_array = get_dates_array(time_slot_dates)
      paid_checked_in = event.tickets.where(ticket_type: 'buy').map {|t| t.redemptions.where(created_at: dates_array).size }.sum   
end


def get_time_slot_movement_in_event_attendees(current_time_slot_dates, before_current_time_slot_dates, event)
    current_dates_array = get_dates_array(current_time_slot_dates)
    before_dates_array = get_dates_array(before_current_time_slot_dates)
    
    current_size = 0
    before_size = 0

    current_size += event.going_interest_levels.where(created_at: current_dates_array).size
    before_size += event.going_interest_levels.where(created_at:before_dates_array).size
  
    movement_percent_before = get_percent_of(before_size, event.event.max_attendees)
    movement_percent_now =   get_percent_of(current_size, event.event.max_attendees)

    differenct_in_movement_percent =  movement_percent_now - movement_percent_before 
    differenct_in_movement_percent.round(2)

end


def get_dates_array(current_time_slot_dates)
  dates = current_time_slot_dates.map {|date| Date.parse(date) }
  dates_array = dates.map {|d| d.midnight..d.end_of_day }
end


end
