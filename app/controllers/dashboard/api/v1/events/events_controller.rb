 class Dashboard::Api::V1::Events::EventsController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request

  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

    resource_description do
      api_versions "dashboard"
    end

  api :GET, 'dashboard/api/v1/get-list', 'Get all events'

  def index

    @events = request_user.child_events.order(start_date: 'ASC').map {|e| get_dashboard_child_event_object(e) }
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        events: @events
      }
    }
  end

  api :POST, 'dashboard/api/v1/events', 'To view a specific event'
  param :id, :number, :desc => "Title of the competition", :required => true

  def show
   e = Event.find(params[:id])
   sponsors = []
   additional_media = []

   admission_resources = {
     "ticketes" => e.tickets,
     "passes" => e.passes
   }
   if !e.sponsors.blank?
     e.sponsors.each do |sponsor|
     sponsors << {
      "id": sponsor.id,
       "sponsor_image" => sponsor.sponsor_image.url,
       "external_url" => sponsor.external_url
     }
    end #each
   end

   if !e.event_attachments.blank?
     e.event_attachments.each do |attachment|
     additional_media << {
      "id": attachment.id,
       "media_type" => attachment.media_type,
       "media" => attachment.media.url
     }
    end#each
   end
    qr = []
     if !e.passes.blank?
       e.passes.map {|p| qr.push(p.qr_code) }
     end
  case
  when e.start_date.to_date == Date.today
  status =  "Now On"
  when e.start_date.to_date > Date.today && e.price_type == "free_ticketed_event" || e.price_type == "pay_at_door" || e.price_type == "free_event"
    status =  e.going_interest_levels.size.to_s + " Going"  
  when e.start_date.to_date > Date.today && e.price_type == "buy"
    status =  e.tickets.map { |e| e.wallets}.size.to_s + " Tickets Gone"
  when e.start_date.to_date < Date.today
   status = "Event Over"
  end

   @event = {
     'id' => e.id,
     'title' => e.title,
     'start_date' => e.start_date,
     'end_date' => e.end_date,
     'image' => e.image.url,
     'location' => jsonify_location(e.location),
     'description' => e.description,
     'categories' => e.categories,
     "allow_chat" => e.allow_chat,
     "event_forwarding" => e.event_forwarding,
     'admission_resources' => admission_resources,
     'sponsors' => sponsors,
     "terms_conditions" => e.terms_conditions,
     'event_attachments' => additional_media,
     'creator_name' => get_full_name(e.user),
     'creator_id' => e.user.id,
     'creator_image' => e.user.avatar,
     'event_status' => e.status,
     'event_type' => e.event_type,
     'over_18' => e.over_18,
     'quantity' => e.quantity,
     'price_type' => e.price_type,
     "price" => get_price(e),
     'is_repetive' => e.is_repetive,
     'frequency' => e.frequency,
     "qr_code" => qr,
     'max_attendees' => e.max_attendees,
     "get_demographics" => get_demographics(e),
     "going" => e.going_interest_levels.size,
     "maybe" => e.interested_interest_levels.size,
     "status" => status,
     'repeatEndDate' => e.child_events.maximum('start_date'),
     'pass_id' => e.passes.map { |e| e.id }.to_sentence,
     "event_dates" => e.child_events.map {|ch| 
        {
          id: ch.id,
          date: ch.start_date.to_date
        }

      },
     "child_events" => e.child_events.map {|child_event| 
        {
          id: child_event.id,
          going: child_event.going_interest_levels.size,
          maybe: child_event.interested_interest_levels.size,
          get_demographics: get_demographics(child_event)
        }

      }

  }

   render json: {
     code: 200,
     success: true,
     message: '',
     data: {
       event: @event
     }
   }
  end



  def user_events
    @events = []
    request_user.events.page(params[:page]).per(20).each do |e|
      sponsors = []
      additional_media = []
      location = {
        "name" => e.location,
        "geometry" => {
          "lat" => e.lat,
          'lng' => e.lng
        }
      }

      admission_resources = {
        "ticketes" => e.tickets,
        "passes" => e.passes
      }

      if !e.sponsors.blank?
        e.sponsors.each do |sponsor|
        sponsors << {
          "sponsor_image" => sponsor.sponsor_image.url,
          "external_url" => sponsor.external_url
        }
       end #each
      end

      if !e.event_attachments.blank?
        e.event_attachments.each do |attachment|
        additional_media << {
          "media_type" => attachment.media_type,
          "media" => attachment.media.url
        }
       end#each
      end

      @events << {
        'id' => e.id,
        'name' => e.title,
        'start_date' => e.start_date,
        'end_date' => e.end_date,
        'image' => e.image.url,
        'location' => jsonify_location(location),
        'description' => e.description,
        "terms_conditions" => e.terms_conditions,
        'categories' => e.categories,
        'admission_resources' => admission_resources,
        'sponsors' => sponsors,
        'event_attachments' => additional_media,
        'creator_name' => get_full_name(e.user),
        'creator_id' => e.user.id,
        'creator_image' => e.user.avatar,
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

  api :GET, 'dashboard/api/v1/events', 'To view a past/expired events'

  def get_past_events
    @events = []
    request_user.events.page(params[:page]).per(20).expired.each do |e|
      stats = {}
      location = {}
      location = {
         "name" => e.location,
         "geometry" => {
           "lat" => e.lat,
           'lng' => e.lng
         }
      }

        stats['going_count'] = e.going_interest_levels.size
        stats['views_count'] = e.views.size
        stats['total_tickets'] = if e.ticket then e.ticket.quantity else 0 end
        stats['redeemed_passes'] =  get_redeemed_passes(e)
        stats['vips_count'] = 0
        stats['sales_count'] = 0

      @events << {
        'id' => e.id,
        'title' => e.title,
        'date' => e.start_date,
        'image' => e.image.url,
        "terms_conditions" => e.terms_conditions,
        'creator_name' => e.user.business_profile.profile_name,
        'creator_id' => e.user.id,
        'creator_image' => e.user.avatar,
        'location' => jsonify_location(location),
        'lat' => e.lat,
        'lng' => e.lng,
        'stats' => stats
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

  api :POST, 'dashboard/api/v1/events', 'To create an event'
  # param :name, String, :desc => "Name of the event", :required => true
  # param :description, String, :desc => "Description of the event", :required => true
  # param :image, String, :desc => "Image of the event", :required => true
  # param :start_date, String, :desc => "Start date of the event", :required => true
  # param :end_date, String, :desc => "Event of the event", :required => true
  # param :over_18, String, :desc => "Title of the competition", :required => true
  # param :terms_conditions, String, :desc => "Title of the competition", :required => true
  # param :allow_chat, ['true', 'false'], :desc => "Title of the competition", :required => true
  # param :event_forwarding, ['true', 'false'], :desc => "Title of the competition", :required => true
  # #param :location, :number, :desc => "Title of the competition", :required => true
  #  param :free, Hash, :desc => "One of the admission resource is required", :required => true  do
  #   param :title, String, 'Title of the free Ticket'
  #   param :quantity, :number, 'Quantity of the free tickets'
  #   param :per_head, :number, 'Per Head'
  # end

  #  param :paid, Hash, :desc => "One of the admission resource is required", :required => true  do
  #   param :title, String, 'Title of the free Ticket'
  #   param :quantity, :number, 'Quantity of the free tickets'
  #   param :per_head, :number, 'Per Head'
  #   param :price, :decimal, 'Price of the paid ticket'
  # end

  # param :pay_at_door, Hash, :desc => "One of the admission resource is required", :required => true  do
  #   param :start_price, :decimal, 'Start Price of the pay at door ticket'
  #   param :end_price, :decimal, 'End Price of the pay at door ticket'
  # end


  def add_admission_resource
    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
        @error_messages = []

        if params[:price_type] != "free_event"
          params[:admission_resources].each do |resource|
            case resource[:name]
            when "free"
              required_fields = ['title', 'quantity', 'per_head']
              resource[:fields].each do |f|
                required_fields.each do |field|
                  if f[field.to_sym].blank?
                    @error_messages.push("In free ticket " + field + ' is required.')
                  end #if
                end #each
               end #each

            when 'buy'
              required_fields = ['title', 'quantity', 'per_head','price']
              resource[:fields].each do |f|
                required_fields.each do |field|
                  if f[field.to_sym].blank?
                    @error_messages.push("In paid ticket " + field + ' is required.')
                  end #if
                end #each
              end #each

              when 'pay_at_door'
               required_fields = ['start_price', 'end_price']
               resource[:fields].each do |f|
                required_fields.each do |field|
                  if f[field.to_sym].blank?
                    @error_messages.push("In pay at door " + field + ' is required.')
                  end #if
                 end #each
               end #each

              when 'pass'
                required_fields = ['title', 'valid_from','valid_to','quantity']
                resource[:fields].each do |f|
                  required_fields.each do |field|
                    if f[field.to_sym].blank?
                      @error_messages.push("In pass " + field + ' is required.')
                    end #if
                   end #each
                 end #each

              else
                @error_messages.push('invalid resource type is submitted.')
                process_validated = false
              end
            end #each
          end

          if params[:price_type] == "free_event"
              @event.update!(price_type: "free_event", price: 0.00, quantity: params[:quantity])
              @event.child_events.map { |e| e.update!(price_type: "free_event", price: 0.00, quantity: params[:quantity])}
          # Admisssion sectiion
          else !params[:admission_resources].blank?
            params[:admission_resources].each do |resource|


            case resource[:name]
            when "free"
                resource[:fields].each do |f|
                 if f.include? "id"
                    @ticket = @event.tickets.find(f[:id]).update!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], terms_conditions: f[:terms_conditions],  user: request_user, ticket_type: 'free', price: 0)
                  else
                    @ticket = @event.tickets.create!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], terms_conditions: f[:terms_conditions],  user: request_user, ticket_type: 'free', price: 0)
                  end
                end #each
                @event.update!(price: 0.00, start_price: 0.00, end_price: 0.00, price_type: "free_ticketed_event", max_attendees: @event.tickets.map { |e| e.quantity}.sum)
                @event.child_events.map { |e| e.update!(price_type: "free_ticketed_event", price: 0.00, start_price: 0.00, end_price: 0.00,) }
             when 'buy'
                prices = []
                tickets_done = false
                resource[:fields].each do |f|
                  if f.include? "id"
                    if @event.tickets.find(f[:id]).update!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], terms_conditions: f[:terms_conditions], price: f[:price], user: request_user, ticket_type: 'buy')
                      tickets_done = true
                    else
                      tickets_done = false
                    end
                  else
                    if @event.tickets.create!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], price: f[:price], terms_conditions: f[:terms_conditions], user: request_user, ticket_type: 'buy')  
                      tickets_done = true
                    else
                      tickets_done = false
                    end               
                  end
                 prices.push(f[:price])
                end #each
                 if tickets_done
                 @event.update!(price: prices.max, start_price: 0.00, end_price: 0.00, price_type: "buy", max_attendees: @event.tickets.map { |e| e.quantity}.sum)
                 @event.child_events.map { |e| e.update!(price_type: "buy", price: prices.max, start_price: 0.00, end_price: 0.00) }
                 end
              when 'pay_at_door'
                resource[:fields].each do |f|
                  if f.include? "id"
                    @ticket = @event.tickets.find(f[:id]).update!(start_price: f[:start_price], quantity: f[:quantity], end_price: f[:end_price], terms_conditions: f[:terms_conditions], user: request_user, ticket_type: 'pay_at_door')
                  else
                    @ticket = @event.tickets.create!(start_price: f[:start_price], quantity: f[:quantity], end_price: f[:end_price], user: request_user, ticket_type: 'pay_at_door')
                  end  
                end #each
                @event.update!(price: 0.00, start_price: resource[:fields][0] ["start_price"], end_price:resource[:fields][0] ["end_price"], price_type: "pay_at_door", max_attendees: @event.tickets.map { |e| e.quantity}.sum)
                @event.child_events.map { |e| e.update!(price_type: "pay_at_door", price: 0.00, start_price: resource[:fields][0] ["start_price"], end_price:resource[:fields][0] ["end_price"]) }

              when 'pass'
                passes_done = false
                resource[:fields].each do |f|
                if f.include? "id"
                    if @event.passes.find(f[:id]).update!(user: request_user, title: f[:title], valid_from: f[:valid_from], valid_to: f[:valid_to], validity: f[:valid_to], quantity: f[:quantity], terms_conditions: f[:terms_conditions],  ambassador_rate: f[:ambassador_rate], qr_code: generate_code)
                      passes_done = true
                    else
                      passes_done = false
                    end
                else
                      if @event.passes.create!(user: request_user, title: f[:title], valid_from: f[:valid_from], valid_to: f[:valid_to], validity: f[:valid_to], quantity: f[:quantity], terms_conditions: f[:terms_conditions],  ambassador_rate: f[:ambassador_rate], qr_code: generate_code)
                        passes_done = true
                      else
                        passes_done = false
                      end
                end
                if passes_done 
                  @event.update!(pass: 'true')
                  @event.child_events.map {|ch| ch.update!(pass: 'true') }
                end
              end
              else
                @error_messages.push('invalid resource type is submitted.')
              end
            end #each
          end#if

          if @event.save
            render json:  {
              code: 200,
              success: true,
              message: 'Admission Resource successfully added.',
              data: {
                 event: (@event),
                 admission_resources: @event.tickets,
                 passes: @event.passes
              }
            }
          else
            render json:  {
              code: 400,
              success: false,
              message: @event.error_messages,
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

  def add_sponsor
    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
      if !params[:sponsors].blank?
        params[:sponsors].each do |sponsor|
          if sponsor.include? "id"
            @event_sponsor = @event.sponsors.find(sponsor[:id]).update!(:external_url => sponsor[:external_url],:sponsor_image => sponsor[:sponsor_image])
          else
            @event_sponsor = @event.sponsors.create!(:external_url => sponsor[:external_url],:sponsor_image => sponsor[:sponsor_image])
          end
        end #each
      end#if
        render json:  {
          code: 200,
          success: true,
          message: 'Sponsor succesfully added.',
          data: {
             event: @event,
             sponsors: @event.sponsors
          }
        }
    else
      render json: {
        code: 400,
        success: false,
        message: 'event_id is required.',
        data: nil
      }
    end
  end



  def add_media
    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
      if !params[:event_attachments].blank?
        params[:event_attachments].each do |attachment|
          if attachment.include? "id"
            @event_attachment = @event.event_attachments.find(attachment[:id]).update!(:media => attachment[:media], media_type: 'image')
          else
            @event_attachment = @event.event_attachments.create!(:media => attachment[:media], media_type: 'image')
          end
         end
        end #if
        render json:  {
          code: 200,
          success: true,
          message: 'Media succesfully added.',
          data: {
             event: @event,
             event_attachments: @event.event_attachments
          }
        }
    else
      render json: {
        code: 400,
        success: false,
        message: 'event_id is required.',
        data: nil
      }
    end
  end

  def add_social
    if !params[:event_id].blank?
     @event = Event.find(params[:event_id])

     @event.event_forwarding = params[:event_forwarding]
     @event.allow_chat = params[:allow_chat]

     if @event.save
        render json:  {
          code: 200,
          success: true,
          message: 'Social succesfully added.',
          data: {
             event: @event
          }
        }
     else
        render json:  {
          code: 400,
          success: false,
          message: @event.error_messages,
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

  def add_times
    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
      @event.start_date = get_date_time(params[:start_date].to_date, params[:start_time])
      @event.end_date = get_date_time(params[:end_date].to_date, params[:end_time])
      @event.frequency = params[:frequency]
      @event.is_repetive = params[:is_repetive]
        if @event.save
            @event.child_events.where.not(start_date: params[:event_dates]).destroy_all
              params[:event_dates].each do |date|
                ch = @event.child_events.where(start_date: date).first
                if ch.blank?
                  @event.child_events.create!(
                      user_id: request_user.id,
                      title: @event.title,
                      venue: @event.venue,
                      image: @event.image,
                      start_date: get_date_time(date.to_date, params[:start_time]),
                      end_date: get_date_time(date.to_date, params[:end_time]),
                      first_cat_id: @event.first_cat_id,
                      description: @event.description,
                      # terms_conditions: params[:terms_conditions],
                      allow_chat: "",
                      event_forwarding: "" ,
                      location: @event.location,
                      location_name: "",
                      event_type: @event.event_type,
                      price_type: "",
                      price: ""
                    )
                else
                  @event.child_events.find_by(start_date: date).update!(
                    user_id: request_user.id,
                    title: @event.title,
                    venue: @event.venue,
                    image: @event.image,
                    start_date: get_date_time(date.to_date, params[:start_time]),
                    end_date: get_date_time(date.to_date, params[:end_time]),
                    first_cat_id: @event.first_cat_id,
                    description: @event.description,
                    # terms_conditions: params[:terms_conditions],
                    allow_chat: "",
                    event_forwarding: "" ,
                    location: @event.location,
                    location_name: "",
                    event_type: @event.event_type,
                    price_type: "",
                    price: ""
                    )
                end    
              end

        render json:  {
          code: 200,
          success: true,
          message: 'Time succesfully added.',
          data: {
             event: @event,
             child_events: @event.child_events
          }
        }
        else
        render json:  {
          code: 400,
          success: false,
          message: @event.error_messages,
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


  def publish_event
    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
      @event.status = "active"

      if @event.save
        render json:  {
          code: 200,
          success: true,
          message: 'Time succesfully added.',
          data: {
             event: @event
          }
        }
      else
        render json:  {
          code: 400,
          success: false,
          message: @event.error_messages,
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

  def create_event

    success = false
    # @error_messages = []

    # if params[:price_type] != "free_event"
    #   params[:admission_resources].each do |resource|
    #     case resource[:name]
    #     when "free"
    #       required_fields = ['title', 'quantity', 'per_head']
    #       resource[:fields].each do |f|
    #         required_fields.each do |field|
    #           if f[field.to_sym].blank?
    #             @error_messages.push("In free ticket " + field + ' is required.')
    #           end #if
    #         end #each
    #        end #each

    #     when 'buy'
    #       required_fields = ['title', 'quantity', 'per_head','price']
    #       resource[:fields].each do |f|
    #         required_fields.each do |field|
    #           if f[field.to_sym].blank?
    #             @error_messages.push("In paid ticket " + field + ' is required.')
    #           end #if
    #         end #each
    #       end #each

    #       when 'pay_at_door'
    #        required_fields = ['start_price', 'end_price']
    #        resource[:fields].each do |f|
    #         required_fields.each do |field|
    #           if f[field.to_sym].blank?
    #             @error_messages.push("In pay at door " + field + ' is required.')
    #           end #if
    #          end #each
    #        end #each

    #       when 'pass'
    #         required_fields = ['title', 'valid_from','valid_to','quantity']
    #         resource[:fields].each do |f|
    #           required_fields.each do |field|
    #             if f[field.to_sym].blank?
    #               @error_messages.push("In pass " + field + ' is required.')
    #             end #if
    #            end #each
    #          end #each

    #       else
    #         @error_messages.push('invalid resource type is submitted.')
    #         process_validated = false
    #       end
    #     end #each
    #   end

     # if !params[:sponsors].blank?
     #  required_fields = ['sponsor_image', 'external_url']
     #  params[:sponsors].each do |sponsor|
     #    required_fields.each do |field|
     #      if sponsor[field.to_sym].blank?
     #        @error_messages.push("In sponsors " + field + ' is required.')
     #      end #if
     #     end #each
     #  end #each
     # end #blank

     # if !params[:event_attachments].blank?
     #  required_fields = ['media']
     #  params[:event_attachments].each do |attachment|
     #    required_fields.each do |field|
     #      if attachment[field.to_sym].blank?
     #        @error_messages.push("In event attachements " + field + ' is required.')
     #      end #if
     #     end #each
     #  end #each
     # end #blank
    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
      @event.title = params[:title]
      @event.image = params[:image]
      @event.start_date = ""
      @event.end_date = ""
      @event.venue = params[:venue]
      @event.over_18 = params[:over_18]
      @event.description = params[:description]
      @event.allow_chat = ""
      @event.event_forwarding = ""
      @event.location = params[:location]
      @event.location_name = ""
      @event.event_type = params[:event_type]
      # @event.qr_code = generate_code
      @event.category_ids = params[:category_ids]
      @event.first_cat_id =  params[:category_ids].first if params[:category_ids]
      # @event.terms_conditions = params[:terms_conditions]
      @event.quantity = ""
      @event.is_repetive = ""
      @event.frequency = ""
      @event.price = ""
    else
      @event = request_user.events.new
      @event.title = params[:title]
      @event.image = params[:image]
      @event.start_date = ""
      @event.end_date = ""
      @event.venue = params[:venue]
      @event.over_18 = params[:over_18]
      @event.description = params[:description]
      @event.allow_chat = ""
      @event.event_forwarding = ""
      @event.location = params[:location]
      @event.location_name = ""
      @event.event_type = params[:event_type]
      # @event.qr_code = generate_code
      @event.category_ids = params[:category_ids]
      @event.first_cat_id =  params[:category_ids].first if params[:category_ids]
      # @event.terms_conditions = params[:terms_conditions]
      @event.quantity = ""
      @event.is_repetive = ""
      @event.frequency = ""
      @event.price = ""
      @event.status = "draft"
    end

    if @event.save
      # params[:event_dates].map { |date| @event.child_events.create!(
      #       user_id: request_user.id,
      #       name: params[:name],
      #       image: params[:image],
      #       start_date: "",
      #       end_date: "",
      #       over_18: params[:over_18],
      #       first_cat_id: params[:category_ids].first,
      #       description: params[:description],
      #       # terms_conditions: params[:terms_conditions],
      #       allow_chat: "",
      #       event_forwarding: "" ,
      #       location: params[:location],
      #       location_name: params[:location][:full_address],
      #       event_type: params[:event_type],
      #       price_type: "",
      #       price: ""
      #     )}

        success = true

      # if params[:price_type] == "free_event"
      #     @event.update!(price_type: "free_event", price: 0.00)
      #     @event.child_events.map { |e| e.update!(price_type: "free_event", price: 0.00) }
      # # Admisssion sectiion
      # else !params[:admission_resources].blank?
      #   params[:admission_resources].each do |resource|


      #   case resource[:name]
      #   when "free"
      #       resource[:fields].each do |f|
      #        @ticket = @event.tickets.create!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], terms_conditions: f[:terms_conditions], user: request_user, ticket_type: 'free', price: 0)
      #       end #each
      #       @event.update!(price: 0.00, start_price: 0.00, end_price: 0.00, price_type: "free_ticketed_event", max_attendees: @event.tickets.map { |e| e.quantity}.sum)
      #       @event.child_events.map { |e| e.update!(price_type: "free_ticketed_event", price: 0.00, start_price: 0.00, end_price: 0.00,) }
      #    when 'buy'
      #       prices = []
      #       tickets_done = false
      #       resource[:fields].each do |f|
      #        if @event.tickets.create!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], terms_conditions: f[:terms_conditions], price: f[:price], user: request_user, ticket_type: 'buy')
      #        prices.push(f[:price])
      #        tickets_done = true
      #        else
      #         tickets_done = false
      #        end
      #       end #each
      #        if tickets_done
      #        @event.update!(price: prices.max, start_price: 0.00, end_price: 0.00, price_type: "buy", max_attendees: @event.tickets.map { |e| e.quantity}.sum)
      #        @event.child_events.map { |e| e.update!(price_type: "buy", price: prices.max, start_price: 0.00, end_price: 0.00) }
      #        end
      #     when 'pay_at_door'
      #       resource[:fields].each do |f|
      #        @ticket = @event.tickets.create!(start_price: f[:start_price], end_price: f[:end_price], quantity: f[:quantity], terms_conditions: f[:terms_conditions], user: request_user, ticket_type: 'pay_at_door')
      #       end #each
      #       @event.update!(price: 0.00, start_price: resource[:fields][0] ["start_price"], end_price:resource[:fields][0] ["end_price"], price_type: "pay_at_door", max_attendees: @event.tickets.map { |e| e.quantity}.sum)
      #       @event.child_events.map { |e| e.update!(price_type: "pay_at_door", price: 0.00, start_price: resource[:fields][0] ["start_price"], end_price:resource[:fields][0] ["end_price"]) }

      #     when 'pass'
      #       passes_done = false
      #       resource[:fields].each do |f|
      #      if @event.passes.create!(user: request_user, title: f[:title], validity: f[:valid_to], quantity: f[:quantity], ambassador_rate: f[:ambassador_rate], per_head: f[:per_head])
      #        passes_done = true
      #      else
      #       passes_done = false
      #      end  
      #     end #each
      #     if passes_done 
      #       @event.update!(pass: 'true')
      #       @event.child_events.map {|ch| ch.update!(pass: 'true') }
      #     end
      #     else
      #       @error_messages.push('invalid resource type is submitted.')
      #     end
      #   end #each
      # end#if


    #save attachement if there is any
    # if !params[:event_attachments].blank?
    #   params[:event_attachments].each do |attachment|
    #     @event_attachment = @event.event_attachments.new(:media => attachment[:media], media_type: 'image')
    #     @event_attachment.save
    #    end
    #   end #if

    #   #save sponsers if there is any
    #   if !params[:sponsors].blank?
    #     params[:sponsors].each do |sponsor|
    #     @event_sponsor = @event.sponsors.create!(:external_url => sponsor[:external_url],:sponsor_image => sponsor[:sponsor_image])
    #     end #each
    #   end#if

    end#if

     if success
        render json:  {
          code: 200,
          success: true,
          message: 'Event successfully created.',
          data: {
             event: (@event)
          }
        }
      else
        render json: {
          code: 400,
          success: false,
          message: @event.errors.full_messages,
          data: nil
        }
      end
  end


  api :POST, 'dashboard/api/v1/events', 'To update an event'
  # param :id, :number, :desc => "ID of the event", :required => true
  # param :name, String, :desc => "Name of the event", :required => true
  # param :description, String, :desc => "Description of the event", :required => true
  # param :image, String, :desc => "Image of the event", :required => true
  # param :start_date, String, :desc => "Start date of the event", :required => true
  # param :end_date, String, :desc => "Event of the event", :required => true

  # param :over_18, String, :desc => "Title of the competition", :required => true
  # param :terms_conditions, String, :desc => "Title of the competition", :required => true
  # param :allow_chat, ['true', 'false'], :desc => "Title of the competition", :required => true
  # param :event_forwarding, ['true', 'false'], :desc => "Title of the competition", :required => true
  # #param :location, String, :desc => "Title of the competition", :required => true
  #  param :free, Hash, :desc => "One of the admission resource is required", :required => true  do
  #   param :title, String, 'Title of the free Ticket'
  #   param :quantity, :number, 'Quantity of the free tickets'
  #   param :per_head, :number, 'Per Head'
  # end

  #  param :paid, Hash, :desc => "One of the admission resource is required", :required => true  do
  #   param :title, String, 'Title of the free Ticket'
  #   param :quantity, :number, 'Quantity of the free tickets'
  #   param :per_head, :number, 'Per Head'
  #   param :price, :decimal, 'Price of the paid ticket'
  # end

  # param :pay_at_door, Hash, :desc => "One of the admission resource is required", :required => true  do
  #   param :start_price, :decimal, 'Start Price of the pay at door ticket'
  #   param :end_price, :decimal, 'End Price of the pay at door ticket'
  # end


  # def update

  #   success = false
  #   @error_messages = []

  #   if params[:price_type] != "free_event"
  #     params[:admission_resources].each do |resource|
  #       case resource[:name]
  #       when "free"
  #         required_fields = ['title', 'quantity', 'per_head']
  #         resource[:fields].each do |f|
  #           required_fields.each do |field|
  #             if f[field.to_sym].blank?
  #               @error_messages.push("In free ticket " + field + ' is required.')
  #             end #if
  #           end #each
  #          end #each

  #       when 'buy'
  #         required_fields = ['title', 'quantity', 'per_head','price']
  #         resource[:fields].each do |f|
  #           required_fields.each do |field|
  #             if f[field.to_sym].blank?
  #               @error_messages.push("In paid ticket " + field + ' is required.')
  #             end #if
  #           end #each
  #         end #each

  #         when 'pay_at_door'
  #          required_fields = [ 'start_price', 'end_price']
  #          resource[:fields].each do |f|
  #           required_fields.each do |field|
  #             if f[field.to_sym].blank?
  #               @error_messages.push("In pay at door " + field + ' is required.')
  #             end #if
  #            end #each
  #          end #each

  #         when 'pass'
  #           required_fields = ['title', 'valid_from','valid_to','quantity']
  #           resource[:fields].each do |f|
  #             required_fields.each do |field|
  #               if f[field.to_sym].blank?
  #                 @error_messages.push("In pass " + field + ' is required.')
  #               end #if
  #              end #each
  #            end #each

  #         else
  #           @error_messages.push('invalid resource type is submitted.')
  #           process_validated = false
  #         end
  #       end #each
  #   end

  #    # if !params[:sponsors].blank?
  #    #  required_fields = ['sponsor_image', 'external_url']
  #    #  params[:sponsors].each do |sponsor|
  #    #    required_fields.each do |field|
  #    #      if sponsor[field.to_sym].blank?
  #    #        @error_messages.push("In sponsors " + field + ' is required.')
  #    #      end #if
  #    #     end #each
  #    #  end #each
  #    # end #blank

  #    # if !params[:event_attachments].blank?
  #    #  required_fields = ['media']
  #    #  params[:event_attachments].each do |attachment|
  #    #    required_fields.each do |field|
  #    #      if attachment[field.to_sym].blank?
  #    #        @error_messages.push("In event attachements " + field + ' is required.')
  #    #      end #if
  #    #     end #each
  #    #  end #each
  #    # end #blank

  # if @error_messages.blank?
  #   @event = Event.find(params[:id])
  #   @event.title = params[:name]
  #   @event.image = params[:image]
  #   @event.start_date = params[:start_date]
  #   @event.end_date = params[:end_date]
  #   @event.over_18 = params[:over_18]
  #   @event.description = params[:description]
  #   @event.allow_chat = params[:allow_chat]
  #   @event.event_forwarding = params[:event_forwarding]
  #   @event.location = params[:location]
  #   @event.location_name = params[:location][:full_address]
  #   @event.event_type = params[:event_type]
  #   @event.category_ids = params[:category_ids]
  #   @event.first_cat_id =  params[:category_ids].first if params[:category_ids]
  #   @event.terms_conditions = params[:terms_conditions]
  #   @event.quantity = params[:quantity]
  #   @event.is_repetive = params[:is_repetive]
  #   @event.frequency = params[:frequency]
  #   @event.price = params[:price]

  #   if @event.save
      
  #   @event.child_events.where.not(start_date: params[:event_dates]).destroy_all
  #     params[:event_dates].each do |date|
  #       ch = @event.child_events.where(start_date: date).first
  #       if ch.blank?
  #         @event.child_events.create!(
  #             user_id: request_user.id,
  #             name: params[:name],
  #             image: params[:image],
  #             start_date: date.to_date,
  #             end_date: date.to_date,
  #             over_18: params[:over_18],
  #             description: params[:description],
  #             first_cat_id: params[:category_ids].first,
  #             terms_conditions: params[:terms_conditions],
  #             allow_chat: params[:allow_chat],
  #             event_forwarding: params[:event_forwarding],
  #             location: params[:location],
  #             location_name: params[:location][:full_address],
  #             event_type: params[:event_type],
  #             price_type: params[:price_type],
  #             price: params[:price]
  #           )
  #       else
  #         @event.child_events.find_by(start_date: date).update!(
  #           user_id: request_user.id,
  #             name: params[:name],
  #             image: params[:image],
  #             start_date: date.to_date,
  #             end_date: date.to_date,

  #             over_18: params[:over_18],
  #             description: params[:description],
  #             terms_conditions: params[:terms_conditions],
  #             allow_chat: params[:allow_chat],
  #             event_forwarding: params[:event_forwarding],
  #             location: params[:location],
  #             location_name: params[:location][:full_address],
  #             event_type: params[:event_type],
  #             price_type: params[:price_type],
  #             price: params[:price]
  #           )
  #       end    
  #     end
  #     success = true

  #     if params[:price_type] == "free_event"
  #        @event.update!(price_type: "free_event", price: 0.00)
  #   # Admisssion sectiion
  #         else !params[:admission_resources].blank?
  #           params[:admission_resources].each do |resource|

  #           case resource[:name]
  #           when "free"
  #               resource[:fields].each do |f|
  #                if f.include? "id"
  #                   @ticket = @event.tickets.find(f[:id]).update!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], terms_conditions: f[:terms_conditions],  user: request_user, ticket_type: 'free', price: 0)
  #                 else
  #                   @ticket = @event.tickets.create!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], terms_conditions: f[:terms_conditions],  user: request_user, ticket_type: 'free', price: 0)
  #                 end
  #               end #each
  #                   @event.update!(price: 0.00, start_price: 0.00, end_price: 0.00, price_type: "free_ticketed_event", max_attendees: @event.tickets.map { |e| e.quantity}.sum)
  #                   @event.child_events.map { |e| e.update!(price_type: "free_ticketed_event", price: 0.00, start_price: 0.00, end_price: 0.00,) }
  #            when 'buy'
  #               prices = []
  #               tickets_done = false
  #               resource[:fields].each do |f|
  #                 if f.include? "id"
  #                   if @event.tickets.find(f[:id]).update!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], terms_conditions: f[:terms_conditions], price: f[:price], user: request_user, ticket_type: 'buy')
  #                     tickets_done = true
  #                   else
  #                     tickets_done = false
  #                   end
  #                 else
  #                   if @event.tickets.create!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], price: f[:price], terms_conditions: f[:terms_conditions], user: request_user, ticket_type: 'buy')  
  #                     tickets_done = true
  #                   else
  #                     tickets_done = false
  #                   end               
  #                 end
  #                 prices.push(f[:price])
  #               end #each
  #                 if tickets_done
  #                    @event.update!(price: prices.max, start_price: 0.00, end_price: 0.00, price_type: "buy", max_attendees: @event.tickets.map { |e| e.quantity}.sum)
  #                    @event.child_events.map { |e| e.update!(price_type: "buy", price: prices.max, start_price: 0.00, end_price: 0.00) }
  #                 end 
  #             when 'pay_at_door'
  #               resource[:fields].each do |f|
  #                 if f.include? "id"
  #                   @ticket = @event.tickets.find(f[:id]).update!(start_price: f[:start_price], quantity: f[:quantity], end_price: f[:end_price], terms_conditions: f[:terms_conditions], user: request_user, ticket_type: 'pay_at_door')
  #                 else
  #                   @ticket = @event.tickets.create!(start_price: f[:start_price], quantity: f[:quantity], end_price: f[:end_price], user: request_user, ticket_type: 'pay_at_door')
  #                 end             
  #               end #each
  #                 @event.update!(price: 0.00, start_price: resource[:fields][0] ["start_price"], end_price:resource[:fields][0] ["end_price"], price_type: "pay_at_door", max_attendees: @event.tickets.map { |e| e.quantity}.sum)
  #                 @event.child_events.map { |e| e.update!(price_type: "pay_at_door", price: 0.00, start_price: resource[:fields][0] ["start_price"], end_price:resource[:fields][0] ["end_price"]) }   
  #             when 'pass'
  #               passes_done = false
  #               resource[:fields].each do |f|
  #                 if f.include? "id"
  #                   if @event.passes.find(f[:id]).update!(user: request_user, title: f[:title], valid_from: f[:valid_from], valid_to: f[:valid_to], validity: f[:valid_to], quantity: f[:quantity], terms_conditions: f[:terms_conditions],  ambassador_rate: f[:ambassador_rate], qr_code: generate_code)
  #                     passes_done = true
  #                   else
  #                     passes_done = false
  #                   end
  #               else
  #                     if @event.passes.create!(user: request_user, title: f[:title], valid_from: f[:valid_from], valid_to: f[:valid_to], validity: f[:valid_to], quantity: f[:quantity], terms_conditions: f[:terms_conditions],  ambassador_rate: f[:ambassador_rate], qr_code: generate_code)
  #                       passes_done = true
  #                     else
  #                       passes_done = false
  #                     end
  #                 end
  #                 if passes_done 
  #                      @event.update!(pass: 'true')
  #                      @event.child_events.map {|ch| ch.update!(pass: 'true') }
  #                 end
  #               end #each


  #             else
  #               @error_messages.push('invalid resource type is submitted.')
  #             end
  #           end #each
  #         end#if

  #   #save attachement if there is any
  #   if !params[:event_attachments].blank?
  #     params[:event_attachments].each do |attachment|
  #       if attachment.include? "id"
  #         @event_attachment = @event.event_attachments.find(attachment[:id]).update!(:media => attachment[:media], media_type: 'image')
  #       else
  #         @event_attachment = @event.event_attachments.create!(:media => attachment[:media], media_type: 'image')
  #       end
  #      end
  #     end #if

  #     #save sponsers if there is any
  #     if !params[:sponsors].blank?
  #       params[:sponsors].each do |sponsor|
  #         if sponsor.include? "id"
  #           @event_sponsor = @event.sponsors.find(sponsor[:id]).update!(:external_url => sponsor[:external_url],:sponsor_image => sponsor[:sponsor_image])
  #         else
  #           @event_sponsor = @event.sponsors.create!(:external_url => sponsor[:external_url],:sponsor_image => sponsor[:sponsor_image])
  #         end
  #       end #each
  #     end#if

  #   end#if

  #    if success
  #       render json:  {
  #         code: 200,
  #         success: true,
  #         message: 'Event successfully updated.',
  #         data: {
  #            event: get_event_object(@event)
  #         }
  #       }
  #     else
  #       @event.errors.full_messages.each do |msg|
  #         @error_messages.push(msg)
  #       end #each
  #       render json: {
  #         code: 400,
  #         success: false,
  #         message: @error_messages,
  #         data: nil
  #       }
  #     end
  #   else
  #     render json: {
  #       code: 400,
  #       success: false,
  #       message: @error_messages,
  #       data: nil
  #     }
  #   end
  # end


    def get_categories
      @categories = Category.all
      render json: {
        code: 200,
        success: true,
        data: {
          categories: @categories
        }
      }
    end

  api :POST, 'dashboard/api/v1/cancel-event', 'To cancel an event'
  param :event_id, :number, :desc => "ID of the event", :required => true

    def cancel_event

    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
      if @event.update(status: 'cancelled')
        render json: {
          code: 200,
          success: true,
          message: "Event successfully cancelled.",
          data: nil
        }
      else
        render json: {
          code: 400,
          success: false,
          message: "Event cancellation failed.",
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

  api :POST, 'dashboard/api/v1/delete-event', 'To delete the event'
  param :event_id, :number, :desc => "ID of the event", :required => true

    def delete_event
      if !params[:event_id].blank?
      event = Event.find(params[:event_id])
      if event.status == "cancelled"
         if event.destroy
           render json: {
             code: 200,
             success: true,
             message: 'Event successfully deleted.',
             data: nil
           }
         else
          render json: {
            code: 400,
            message: 'Event deletion failed.',
            data: nil
          }
         end
      else

        render json: {
          code: 400,
          success: false,
          message: 'In order to delete event first it needs to be cancelled.',
          data: nil
        }
      end
  else
    render json: {
      code: 400,
      success: false,
      message: "Event ID is required",
      data: nil
    }
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
      when 'event_attachment'
       if EventAttachment.find(id).destroy
        success = true
       end
      when 'sponsor'
       if Sponsor.find(id).destroy
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

 def get_date_time(date, time)
    d = date.strftime("%Y-%b-%d")
    t = time.to_time.strftime("%H:%M:%S")
    datetime = d + " " + t
 end


  def setCategories
    @categories = Category.all
  end

  def event_params
		params.permit(:title,:start_date,:end_date,:price,:price_type,:event_type, :external_link, :description,:location,:image, :additional_media, :allow_chat,:event_forwarding,:allow_additional_media,:over_18, :quantity, :is_repetive, :frequency, :category_ids => [], event_attachments_attributes:
    [:id, :event_id, :media])
  end

  def get_sold_tickets(ticket)
    sold_tickets = 0
    if ticket.ticket_purchases
    ticket.ticket_purchases.map {|p| sold_quantity = sold_quantity + p.quantity }
    end
    sold_tickets
  end

  def get_redeemed_passes(e)
    total = 0
    e.passes.each do |pass|
      pass.redemptions.each do |redemption|
        total = total + 1
      end
    end

    total
  end


end
