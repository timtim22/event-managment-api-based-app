class  Api::V1::SearchController < Api::V1::ApiMasterController
  before_action :force_json, only: [:search_friends]

  def add_friends_page
    render  :add_friends
  end

  api :POST, '/api/v1/search/global-search', 'To add user as a friend'
  param :resource_type, String, :desc => "Should be one of the resource type", :required => true
  param :search_term, String, :desc => "Friend ID", :required => true

  def global_search
    @event = []
      if !params[:search_term].blank? && !params[:resource_type].blank?
        case
          when params[:resource_type] == "Event"
            e = ChildEvent.ransack(name_start: params[:search_term]).result(distinct:true).page(params[:page]).per(10).not_expired.order(created_at: "ASC").each do |event|
              @event << {
                  "id" => event.id,
                  "image" => event.image,
                  "name" => event.name,
                  "description" => event.description,
                  "location" => insert_space_after_comma(event.location),
                  "start_date" => event.end_date,
                  "end_date" => event.end_date,
                  "start_time" => event.start_time,
                  "end_time" => event.end_time,
                  "over_18" => event.over_18,
                  "price_type" => get_child_event_price_type(event),
                  "price" => get_child_event_price(event).to_s,
                  "has_passes" => has__child_event_passes?(event),
                  "created_at" => event.created_at,
                  "categories" => event.event.categories
                  }
            end
              render json: {
              code: 200,
              success: true,
              message: '',
              data:  @event
            }
          when params[:resource_type] == "Competition"
          @competitions = []
          if request_user
            Competition.ransack(title_start: params[:search_term]).result(distinct:true).page(params[:page]).per(10).not_expired.order(created_at: "ASC").each do |competition|
              if !is_removed_competition?(request_user, competition) && showability?(request_user, competition) == true
              @competitions << {
                  id: competition.id,
                  title: competition.title,
                  description: competition.description,
                  host_image: competition.user.avatar,
                  image: competition.image.url,
                  is_added_to_wallet: is_added_to_wallet?(competition.id),
                  total_entries_count: get_entry_count(request_user, competition),
                  validity: competition.validity.strftime(get_time_format)
                  }
              end
            end
          else
            Competition.ransack(title_start: params[:search_term]).result(distinct:true).page(params[:page]).not_expired.per(10).order(created_at: "ASC").each do |competition|
              @competitions << {
                  id: competition.id,
                  title: competition.title,
                  description: competition.description,
                  host_image: competition.user.avatar,
                  image: competition.image.url,
                  is_added_to_wallet: is_added_to_wallet?(competition.id),
                  total_entries_count: get_entry_count(request_user, competition),
                  validity: competition.validity.strftime(get_time_format)
                  }
            end
          end
              render json: {
              code: 200,
              success: true,
              message: '',
              data:  @competitions
            }
          when params[:resource_type] == "Pass"
            @passes = []
            passes = Pass.ransack(title_start: params[:search_term]).result(distinct:true).page(params[:page]).not_expired.per(10).order(created_at: "ASC")
              if !passes.blank?
                      passes.each do |pass|
                       if request_user
                        if !is_removed_pass?(request_user, pass)
                          @passes << {
                            id: pass.id,
                            event_name:pass.event.name,
                            event_name:pass.title,
                            pass_type: pass.pass_type,
                            host_image:pass.event.user.avatar,
                            event_image:pass.event.image,
                            is_added_to_wallet: is_added_to_wallet?(pass.id),
                            validity: pass.validity.strftime(get_time_format),
                            is_redeemed: is_redeemed(pass.id, 'Pass', request_user.id)
                          }
                        end
                      else
                        @passes << {
                            id: pass.id,
                            event_name:pass.event.name,
                            pass_type: pass.pass_type,
                            host_image:pass.event.user.avatar,
                            event_image:pass.event.image,
                            is_added_to_wallet: is_added_to_wallet?(pass.id),
                            validity: pass.validity.strftime(get_time_format),
                            is_redeemed: is_redeemed(pass.id, 'Pass', request_user.id)
                        }
                       end
                      end#each
                    end#if
                        render json: {
                        code: 200,
                        success: true,
                        message: '',
                        data:  @passes
                      }
          when params[:resource_type] == "Ticket"
            @tickets = Ticket.ransack(title_start: params[:search_term]).result(distinct:true).page(params[:page]).per(10).order(created_at: "ASC")
              render json: {
              code: 200,
              success: true,
              message: '',
              data:  @tickets
            }
          when params[:resource_type] == "Offer"
            @special_offers = []
            if request_user
              SpecialOffer.ransack(title_start: params[:search_term]).result(distinct:true).page(params[:page]).per(10).not_expired.order(created_at: "ASC").each do |offer|

                if !is_removed_offer?(request_user, offer) && !is_added_to_wallet?(offer.id)
                    @special_offers << {
                    id: offer.id,
                    title: offer.title,
                    offer_total_count: offer.quantity,
                    offer_remaining_count: offer.quantity - offer.wallets.size,
                    image: offer.image.url,
                    host_image: offer.user.avatar,
                    validity: offer.validity.strftime(get_time_format),
                    is_added_to_wallet: is_added_to_wallet?(offer.id),
                    is_redeemed: is_redeemed(offer.id, 'SpecialOffer', request_user.id),
                  }
                end
              end #if
            else
              SpecialOffer.ransack(title_start: params[:search_term]).result(distinct:true).page(params[:page]).per(10).not_expired.order(created_at: "ASC").each do |offer|
                    @special_offers << {
                    id: offer.id,
                    title: offer.title,
                    offer_total_count: offer.quantity,
                    offer_remaining_count: offer.quantity - offer.wallets.size,
                    image: offer.image.url,
                    host_image: offer.user.avatar,
                    validity: offer.validity.strftime(get_time_format),
                    is_added_to_wallet: is_added_to_wallet?(offer.id),
                    is_redeemed: is_redeemed(offer.id, 'SpecialOffer', request_user.id),
                  }
              end
            end
              render json: {
              code: 200,
              success: true,
              message: '',
              data:  @special_offers
            }
        when params[:resource_type] == "User"
            @profiles = []
            @business_profiles = []
            all_users = Hash.new
            profile = Profile.ransack(first_name_or_last_name_start: params[:search_term]).result(distinct:true).page(params[:page]).per(5).order(created_at: "ASC").each do |profile|
              @profiles << {
                id: profile.user.id,
                first_name: profile.first_name,
                last_name: profile.last_name,
                email: profile.user.email,
                avatar: profile.user.avatar,
                phone_number: profile.user.phone_number,
                app_user: profile.user.app_user,
                is_email_verified: profile.user.is_email_verified,
                web_user: profile.user.web_user,
                about: profile.about,
                facebook: profile.facebook,
                twitter: profile.twitter,
                snapchat: profile.snapchat,
                instagram: profile.instagram,
                linkedin: profile.linkedin,
                youtube: profile.youtube,
                is_email_subscribed: profile.is_email_subscribed,
                is_ambassador: profile.is_ambassador,
                earning: profile.earning,
                location: profile.location,
                lat: profile.lat,
                lng: profile.lng,
                device_token: profile.device_token,
                ranking: profile.ranking,
                dob: profile.dob,
                gender: profile.gender,
                is_request_sent: request_status(request_user, profile.user)['status'],
                role: 5,
                is_my_following: false,
                is_my_friend: is_my_friend?(profile.user),
                mutual_friends_count: get_mutual_friends(request_user, profile.user).size,
                location_enabled: profile.user.location_enabled
              }
            end
          business_profile = BusinessProfile.ransack(profile_name_or_contact_name_start: params[:search_term]).result(distinct:true).page(params[:page]).per(5).order(created_at: "ASC").each do |profile|
            @business_profiles << {
              id: profile.user.id,
              profile_name: profile.profile_name,
              contact_name: profile.contact_name,
              display_name: profile.display_name,
              first_name: profile.profile_name,
              last_name: "",
              email: profile.user.email,
              avatar: profile.user.avatar,
              phone_number: profile.user.phone_number,
              app_user: profile.user.app_user,
              is_email_verified: profile.user.is_email_verified,
              web_user: profile.user.web_user,
              vat_number: profile.vat_number,
              charity_number: profile.charity_number,
              address: profile.address,
              about: profile.about,
              facebook: profile.facebook,
              twitter: profile.twitter,
              linkedin: profile.linkedin,
              website: profile.website,
              instagram: profile.instagram,
              is_charity: profile.is_charity,
              is_ambassador: profile.is_ambassador,
              is_request_sent: false,
              is_my_following: is_my_following?(profile.user),
              role: 2,
              is_my_friend: false,
              mutual_friends_count: 0,
              total_followers_count: profile.user.followers.size
            }

          end

          all_users = @business_profiles + @profiles

            # business = User.web_users.ransack(name_cont: params[:search_term]).result(distinct:true).page(params[:page]).per(5).order(created_at: "ASC").map  { |user| all_users.push(get_business_object(user)) }
              render json: {
              code: 200,
              success: true,
              message: '',
              data:  {
                users: all_users
              }
            }

        else
              render json: {
               message: "wrong search type selected. Available resource are Event, Competition, Pass, Offer, Ticket and User."
              }
        end
      else
        render json: {
          code: 400,
          success: false,
          message: 'search_term and search_type are required params',
          data: nil
        }
    end
  end

  def search_events

     search_base_validate = false
     @data = []
     if !params[:search_bases].blank?
      filters = ['name', 'free', 'pass','under_price', 'over_price', 'location']
      submitted_search_bases = params[:search_bases]

      submitted_search_bases.each do |base|
         hash = {}
         hash = base
        if filters.include? base[:base]
          search_base_validate = true #can be used for validation purpose
          search_base = base[:base]
          case search_base
          when "name"
            @q = Event.ransack(name_cont: base[:search_term])
            @events = @q.result(distinct: true)
            if !@events.blank?
             @events.map {|event| @data.push(get_simple_event_object(event)) }
            end
          when "free"
           @events = Ticket.where(ticket_type: 'free').map {|ticket| ticket.event  }
            if !@events.blank?
             @events.map {|event| @data.push(get_simple_event_object(event)) }
            end
          when "pass"
            @events = Pass.all.map {|pass| pass.event }
            if !@events.blank?
              @events.map {|event| @data.push(get_simple_event_object(event)) }
            end
          when "under_price"
            @buy_events = Ticket.where(ticket_type: 'buy').where("price < ?", base[:search_term]).map {|ticket| ticket.event  }
            if !@buy_events.blank?
              @buy_events.map {|event| @data.push(get_simple_event_object(event)) }
            end

             @pay_at_door_events = Ticket.where(ticket_type: 'pay_at_door').where("end_price < ?", base[:q]).map {|ticket| ticket.event  }
            if !@pay_at_door_events.blank?
              @pay_at_door_events.map {|event| @data.push(get_simple_event_object(event)) }
            end

          when "over_price"
            @buy_events = Ticket.where(ticket_type: 'buy').where("price > ?", base[:search_term]).map {|ticket| ticket.event  }
            if !@buy_events.blank?
              @buy_events.map {|event| @data.push(get_simple_event_object(event)) }
            end
             @pay_at_door_events = Ticket.where(ticket_type: 'pay_at_door').where("end_price > ?",
            base[:search_term]).map {|ticket| ticket.event  }
            if !@pay_at_door_events.blank?
              @pay_at_door_events.map {|event| @data.push(get_simple_event_object(event)) }
            end
          when "location"
            @q = Event.ransack(location_cont: base[:search_term])
            @events = @q.result(distinct: true)
            if !@events.blank?
              @events.map {|event| @data.push(get_simple_event_object(event)) }
            end
          else
            'do nothing for now'
          end #switch
        end #if
      end #each
      render json: {
        code: 200,
        success: true,
        message: '',
        data:  {
          result: @data
        }
      }
     else
      render json: {
        code: 400,
        success: false,
        message: "search_bases is requried field and please choose one or multiple search base(s) among allowed search bases 'name', 'free', 'pass','under_price', 'over_price', 'location' ",
        data: nil
      }
    end
  end #func


  def events_live_search
    @q = Event.ransack(name_cont: params[:q])
    events = @q.result(distinct: true).sort_by_date.page(params[:page]).per(30)

    render json: {
      code: 200,
      sucess: true,
      message: '',
      data: {
        result: events
      }
    }

  end




  private
   def force_json
     request.format = :json
   end

    def is_redeemed(offer_id, offer_type,user_id)
      @check = Redemption.where(offer_id: offer_id).where(offer_type: offer_type).where(user_id: user_id)
      if !@check.blank?
         true
      else
        false
      end
    end

  def get_child_event_price_type(event)
    price_type = ''
    if !event.event.tickets.blank?
      price_type = event.event.tickets.first.ticket_type
    else
      price_type = 'no_admission_resources'
    end
     price_type
  end

  def get_child_event_price(event)
    price = ''
    if !event.event.tickets.where(ticket_type: 'buy').blank? && event.event.tickets.size > 1
       prices = event.event.tickets.map {|ticket| ticket.price }
       price =  '€' + event.event.start_price + ' - ' + '€' + event.event.end_price
    elsif !event.event.tickets.where(ticket_type: 'buy').blank? && event.event.tickets.size == 1
       price = '€' + event.event.ticket.price
    elsif !event.event.tickets.where(ticket_type: 'pay_at_door').blank?
       price = '€' + event.event.tickets.first.start_price.to_s +  ' - €' + event.event.tickets.first.end_price.to_s
    else
      price = '0'
   end
   price
 end

  def has__child_event_passes?(event)
    !event.event.passes.blank?
  end


end
