class Dashboard::Api::V1::EventsController < Dashboard::Api::V1::ApiMasterController 
  before_action :authorize_request

  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  
  def index
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
        'name' => e.name,
        'start_date' => e.start_date,
        'end_date' => e.end_date,
        'start_time' => e.start_time,
        'end_time' => e.end_time,
        'image' => e.image.url,
        'location' => location,
        'description' => e.description,
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
        'name' => e.name,
        'date' => e.start_date,
        'time' => e.start_time,
        'image' => e.image.url,
        'creator_name' => e.user.first_name + " " + e.user.last_name,
        'creator_id' => e.user.id,
        'creator_image' => e.user.avatar,
        'location' => location,
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


  def create
    
    process_validated = false
    success = false
    @error_messages = []
    
    if params[:admission_resources].blank?
      render json: {
        code: 400,
        success: false,
        message: 'One of admission process must be defined.',
        data: nil
      }
      return
    else
      params[:admission_resources].each do |resource|
        case resource[:name]
        when "free"
          required_fields = ['title', 'quantity', 'per_head']
          resource[:fields].each do |f|
            required_fields.each do |field|
              if f[field.to_sym].blank?
                process_validated = false
                @error_messages.push("In free ticket " + field + ' is required.')
              else
                process_validated = true
              end #if
            end #each
           end #each
          
        when 'paid'
         

          required_fields = ['title', 'quantity', 'per_head','price']
          resource[:fields].each do |f|
            required_fields.each do |field|
              if f[field.to_sym].blank?
                process_validated = false
                @error_messages.push("In paid ticket " + field + ' is required.')
              else
                process_validated = true
              end #if
            end #each
          end #each
         
          

          when 'pay_at_door'
           required_fields = ['start_price', 'end_price']
           resource[:fields].each do |f|
            required_fields.each do |field|
              if f[field.to_sym].blank?
                process_validated = false
                @error_messages.push("In pay at door " + field + ' is required.')
              else
                process_validated = true
              end #if
             end #each
           end #each
           

          when 'pass'
            required_fields = ['title', 'description', 'valid_from','valid_to','quantity','ambassador_rate']
            resource[:fields].each do |f|
              required_fields.each do |field|
                if f[field.to_sym].blank?
                  process_validated = false
                  @error_messages.push("In pass " + field + ' is required.')
                else
                  process_validated = true
                end #if
               end #each
             end #each
           
          else
            @error_messages.push('invalid resource type is submitted.')
            process_validated = false
          end    
        end #each 
    end
   
  if process_validated
    @event = request_user.events.new
    @event.name = params[:name]
    @event.image = params[:image]
    @event.start_date = params[:start_date]
    @event.end_date = params[:end_date]
    @event.start_time = params['start_time']
    @event.end_time = params['end_time']
    @event.over_18 = params[:over_18]
    @event.description = params[:description]
    @event.price = 0
    @event.allow_chat = params[:allow_chat]
    @event.event_forwarding = params[:event_forwarding]
    if !params[:location].blank? 
    @event.location = params[:location][:name]
    @event.lat = params[:location][:geometry][:lat] 
    @event.lng = params[:location][:geometry][:lng]
    end
    @event.price = params[:price]
    @event.event_type = params[:event_type]
    @event.category_ids = params[:category_ids]
  
    if @event.save
      success = true
    # Admisssion sectiion
    if !params[:admission_resources].blank?
      params[:admission_resources].each do |resource|

      case resource[:name]
      when "free"
          resource[:fields].each do |f|
           @ticket = @event.tickets.create!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], user: request_user, ticket_type: resource[:name], price: 0)
          end #each

       when 'paid'
          resource[:fields].each do |f|
           @ticket = @event.tickets.create!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], price: f[:price], user: request_user, ticket_type: resource[:name])
          end #each

        when 'pay_at_door'
          resource[:fields].each do |f|
           @ticket = @event.tickets.create!(start_price: f[:start_price], end_price: f[:end_price], user: request_user, ticket_type: resource[:name])
          end #each

        when 'pass'
          resource[:fields].each do |f|
          @pass = Pass.create!(event: @event, user: request_user, title: f[:title], valid_from: f[:valid_from], valid_to: f[:valid_to], validity: f[:valid_to], quantity: f[:quantity], ambassador_rate: f[:ambassador_rate])
          @event.update!(pass: 'true')
          end #each

        else
          @error_messages.push('invalid resource type is submitted.')
        end    
      end #each
    end#if

 
    #save attachement if there is any
    if !params[:event_attachments].blank?
      params[:event_attachments]['media'].each do |m|
        @event_attachment = @event.event_attachments.new(:media => m,:event_id => @event.id, media_type: 'image')
        @event_attachment.save
       end
      end #if

      #save sponsers if there is any
      if !params[:sponsors].blank?
        params[:sponsors].each do |sponsor|
        @event_sponsor = @event.sponsors.create!(:external_url => sponsor[:external_url],:sponsor_image => sponsor[:sponsor_image])
        end #each
      end#if

    end#if


     if success
        render json:  {
          code: 200,
          success: true,
          message: 'Event successfully created.',
          data: {
             event: get_event_object(@event)
          }
        }
      else
        @event.errors.full_messages.each do |msg|
          @error_messages.push(msg)
        end #each
        render json: {
          code: 400,
          success: false,
          message: @error_messages,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: @error_messages,
        data: nil
      }
    end
    
  end


  def update
    if !params[:id].blank?
        success = false
        @event = Event.find(params[:id])
        @event.name = params[:name]
        @event.image = params[:image]
        @event.start_date = params[:start_date]
        @event.end_date = params[:end_date]
        @event.start_time = params[:start_time]
        @event.end_time = params[:end_time]
        @event.over_18 = params[:over_18]
        @event.description = params[:description]
        @event.allow_chat = params[:allow_chat]
        @event.event_forwarding = params[:event_forwarding]
        if !params[:location].blank? 
        @event.location = params[:location][:name]
        @event.lat = params[:location][:geometry][:lat] 
        @event.lng = params[:location][:geometry][:lng]
        end
        @event.price = params[:price]
        @event.event_type = "mygo"
        @event.category_ids = params[:category_ids]
        if @event.save
          success = true
        end
        @error_messages = []
        # Admisssion sectiion
        if !params[:admission_resources].blank?
          params[:admission_resources].each do |resource|

          case resource[:name]
          
          when "free"

              resource[:fields].each do |f|

              @ticket = @event.tickets.find(f[:id]).update!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], user: request_user, ticket_type: resource[:name], price: 0)
              end #each

          when 'paid'

              resource[:fields].each do |f|
              @ticket = @event.tickets.find(f[:id]).update!(title: f[:title], quantity: f[:quantity], per_head: f[:per_head], price: f[:price], user: request_user, ticket_type: resource[:name])
              end #each

            when 'pay_at_door'

              resource[:fields].each do |f|
              @ticket = @event.tickets.find(f[:id]).update!(start_price: f[:start_price], end_price: f[:end_price], user: request_user, ticket_type: resource[:name])
              end #each

            when 'pass'

              resource[:fields].each do |f|
                @pass = Pass.find(f[:id]).update!(event: @event, user: request_user, title: f[:title], valid_from: f[:valid_from], valid_to: f[:valid_to], validity: f[:valid_to], quantity: f[:quantity], ambassador_rate: f[:ambassador_rate])
             end #each

            else
              @error_messages.push('invalid resource type is submitted.')
            end    
          end #each
        end#if

    
        #save attachement if there is any
        if !params[:event_attachments].blank?
           @event.event_attachments.destroy_all
          params[:event_attachments]['media'].each do |m|
            @event_attachment = @event.event_attachments.create!(:media => m,:event_id => @event.id, media_type: 'image')
          end
          end #if

          #save sponsers if there is any
          if !params[:sponsors].blank?
            params[:sponsors].each do |sponsor|
             sponsors = @event.sponsors.find(sponsor[:id]).update!(:external_url => sponsor[:external_url],:sponsor_image => sponsor[:sponsor_image])
            end#each
          end#if


        if success
            render json:  {
              code: 200,
              success: true,
              message: 'Event successfully updated.',
              data: {
                event: get_event_object(@event)
              }
            }
          else
            @event.errors.full_messages.each do |msg|
              @error_messages.push(msg)
            end #each
            render json: {
              code: 400,
              success: false,
              message: @error_messages,
              data: nil
            }
          end

        else 

          render json: {
            code: 400,
            success: false,
            message: "id is requrired field.",
            data: nil
          }
        end

  end


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



    def cancel_event

    if !params[:event_id].blank?
      @event = Event.find(params[:event_id])
      if @event.update(is_cancelled: true)
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


    def destroy
      event = Event.find(params[:id])
      if event.is_cancelled == true
         if event.destroy
           render json: {
             code: 200,
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
    end




  private
  def setCategories
    @categories = Category.all
  end
	
  def event_params
		params.permit(:name,:start_date,:end_date,:price,:price_type,:event_type,:start_time, :end_time, :external_link, :host, :description,:location,:image, :feature_media_link, :additional_media, :lat,:lng,:allow_chat,:invitees,:event_forwarding,:allow_additional_media,:over_18, :category_ids => [], event_attachments_attributes: 
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
