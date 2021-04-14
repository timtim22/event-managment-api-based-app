class Dashboard::Api::V1::SpecialOffers::SpecialOffersController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request

    resource_description do
      api_versions "dashboard"
    end

  api :GET, 'dashboard/api/v1/special_offers', 'Get all special offers'

  def index
    @special_offers = request_user.special_offers.page(params[:page]).order(start_time: 'ASC')
    @offers = []
    @special_offers.each do |offer|
      location = {
        name: offer.location,
        geometry: {
          lat: offer.lat,
          lng: offer.lng
        }
      }
        case
        when offer.end_time > Time.now
          redeem_count =  get_redeem_count(offer).to_s + " Redeemed"
        when offer.end_time < Time.now
          redeem_count =  "Finished"
        end

      @offers << {
        id: offer.id,
        title: offer.title,
        image: offer.image.url,
        start_date: offer.start_time.strftime("%Y-%m-%d"),
        end_date: offer.end_time.strftime("%Y-%m-%d"),
        start_time: offer.start_time.strftime("%H:%M"),
        end_time: offer.end_time.strftime("%H:%M"),
        description: offer.description,
        ambassador_rate: offer.ambassador_rate,
        terms_conditions: offer.terms_conditions,
        quantity: offer.quantity,
        limited: offer.limited,
        over_18: offer.over_18,
        terms_conditions: offer.terms_conditions,
        redeem_count: redeem_count.to_s,
        redemptions: offer.redemptions.size,
        offer_publish_status: offer.status,
        get_demographics: get_offer_demographics(offer),
        outlets: offer.outlets.map { |e| {id: e.id, outlet_address: jsonify_location(e.outlet_address)}}
      }
    end
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        special_offers: @offers
      }
    }
  end

  def show
    if !params[:offer_id].blank?
      if SpecialOffer.where(id: params[:offer_id]).exists?
        @special_offer = SpecialOffer.find(params[:offer_id])
        case
        when @special_offer.end_time > Time.now
          redeem_count =  get_redeem_count(@special_offer).to_s + " Redeemed"
        when @special_offer.end_time < Time.now
          redeem_count =  "Finished"
        end
        render json: {
          code: 200,
          success: true,
          message: "single Special Offer",
          data: {
            id: @special_offer.id,
            title: @special_offer.title,
            image: @special_offer.image.url,
            start_date: @special_offer.start_time.strftime("%Y-%m-%d"),
            end_date: @special_offer.end_time.strftime("%Y-%m-%d"),
            start_time: @special_offer.start_time.strftime("%H:%M"),
            end_time: @special_offer.end_time.strftime("%H:%M"),
            description: @special_offer.description,
            terms_conditions: @special_offer.terms_conditions,
            ambassador_rate: @special_offer.ambassador_rate,
            limited: @special_offer.limited,
            quantity: @special_offer.quantity,
            over_18: @special_offer.over_18,
            redeem_count: redeem_count.to_s,
            redemptions: @special_offer.redemptions.size,
            get_demographics: get_offer_demographics(@special_offer),
            outlets: @special_offer.outlets.map { |e| {id: e.id, outlet_address: jsonify_location(e.outlet_address)}}
          }
        }
      else
        render json: {
          code: 400,
          success: false,
          message: 'Special offer doesnt exist',
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: 'Offer id is required',
        data: nil
      }
    end
  end

  def get_past_offers
    @special_offers = []
    SpecialOffer.page(params[:page]).per(20).expired.order(created_at: "DESC").each do |offer|
      location = {
        "name" => offer.location,
        "geometry" => {
          "lat" => offer.lat,
          'lng' => offer.lng
        }
     }

      @special_offers << {
        id: offer.id,
        title: offer.title,
        image: offer.image,
        location: location,
        views: offer.views.size,
        published: offer.created_at.strftime("%a %d %b %y - %H:%M "),
        redeem_count: get_redeem_count(offer),
    }
    end
    render json:  {
      code: 200,
      success: true,
      message: '',
      data:  {
        special_offers: @special_offers
      }
    }
  end

  def add_image
    if params[:offer_id].blank?
      @special_offer = request_user.special_offers.new
      if !params[:image].blank?
        @special_offer.image = params[:image]
        @special_offer.status = "draft"
        @special_offer.start_time = "1970-01-01 00:00:00"
        @special_offer.end_time = "1970-01-01 00:00:00"
          if @special_offer.save
              render json: {
                code: 200,
                success: true,
                message: 'Special offer created and image added successfully',
                data: {
                  id: @special_offer.id,
                  image: @special_offer.image 
                }
              }
          else
              render json: {
                code: 400,
                success: false,
                message: 'Special offer creation failed',
                data: nil
              }
          end
      else
        render json: {
          code: 400,
          success: false,
          message: "Image can't be blank",
          data: nil
        }
      end
    else
      if SpecialOffer.where(id: params[:offer_id]).exists?
        @special_offer = SpecialOffer.find(params[:offer_id])
        if !params[:image].blank?
          @special_offer.image = params[:image]
          if @special_offer.save
              render json: {
                code: 200,
                success: true,
                message: 'Image updated successfully',
                data: {
                  id: @special_offer.id,
                  image: @special_offer.image 
                }
              }
          else
              render json: {
                code: 400,
                success: false,
                message: 'Special updation failed',
                data: nil
              }
          end
        else
          render json: {
            code: 400,
            success: false,
            message: 'Image cant be blank',
            data: nil
          }
        end
      else
          render json: {
            code: 400,
            success: false,
            message: "Special Offer doesnt exist" ,
            data: nil
          }
      end
    end
  end

  def add_details
    if !params[:offer_id].blank?
      if SpecialOffer.where(id: params[:offer_id]).exists?
        if !params[:title].blank? && !params[:description].blank?
        @special_offer = SpecialOffer.find(params[:offer_id])

          @special_offer.title = params[:title]
          @special_offer.description = params[:description]
          @special_offer.over_18 = params[:over_18]
          if params[:limited] == true
            @special_offer.limited = true
            @special_offer.quantity = params[:quantity]
          else
            @special_offer.limited = false
            @special_offer.quantity = 0
          end

          @special_offer.save

              render json: {
                code: 200,
                success: true,
                message: 'Details added successfully',
                data: {
                  id: @special_offer.id,
                  title: @special_offer.title, 
                  description: @special_offer.description, 
                  over_18: @special_offer.over_18, 
                  limited: @special_offer.limited, 
                  quantity: @special_offer.quantity 
                }
              }
        else
          render json: {
            code: 400,
            success: false,
            message: "Title, and Description cant be blank" ,
            data: nil
          }
        end
      else
          render json: {
            code: 400,
            success: false,
            message: "Special Offer doesnt exist" ,
            data: nil
          }
      end
    else
          render json: {
            code: 400,
            success: false,
            message: "offer_id is required" ,
            data: nil
          }
    end
  end

  def add_time
    if !params[:offer_id].blank?
      if SpecialOffer.where(id: params[:offer_id]).exists?
        @special_offer = SpecialOffer.find(params[:offer_id])
        if !params[:start_date].blank? && !params[:start_time].blank? && !params[:end_date].blank? && !params[:end_time].blank?
          @special_offer.start_time = get_date_time(params[:start_date].to_date, params[:start_time])
          @special_offer.end_time = get_date_time(params[:end_date].to_date, params[:end_time])
          @special_offer.save
              render json: {
                code: 200,
                success: true,
                message: 'Time added successfully',
                data: {
                  id: @special_offer.id,
                  start_time: @special_offer.start_time, 
                  end_time: @special_offer.end_time
                }
              }
        else
        render json: {
          code: 400,
          success: false,
          message: "start_date, start_time, end_date and end_time are required " ,
          data: nil
        }
        end
      else
        render json: {
          code: 400,
          success: false,
          message: "Special Offer doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "offer_id is required" ,
        data: nil
      }
    end
  end

  def add_outlets
    if !params[:offer_id].blank?
      if SpecialOffer.where(id: params[:offer_id]).exists?
        @special_offer = SpecialOffer.find(params[:offer_id])
        params[:outlets].each do |f|
          if f.include? "id"
            @special_offer.outlets.find(f[:id]).update!(outlet_address: f[:outlet_address])
          else
            @special_offer.outlets.create!(outlet_address: f[:outlet_address])
          end
        end

        @special_offer.save
            render json: {
              code: 200,
              success: true,
              message: 'outlets added successfully',
              data: {
                id: @special_offer.id,
                outlets: @special_offer.outlets.map { |e| {id: e.id, outlet_address: jsonify_location(e.outlet_address)}}
              }
            }
      else
        render json: {
          code: 400,
          success: false,
          message: "Special Offer doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "offer_id is required" ,
        data: nil
      }
    end
  end

  def remove_outlet
    if !params[:outlet_id].blank?
      if Outlet.where(id: params[:outlet_id]).exists?
          @outlet = Outlet.find(params[:outlet_id])
          if @outlet.destroy
            render json: {
              code: 200,
              success: true,
              message: "Outlet deleted successfully" ,
              data: nil
            }
          else
            render json: {
              code: 400,
              success: false,
              message: "outlet deletion failed" ,
              data: nil
            }
          end
      else
        render json: {
          code: 400,
          success: false,
          message: "Outlet doesnt exist with the following ID" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "outlet_id is required" ,
        data: nil
      }
    end
  end

  def terms_conditions
    if !params[:offer_id].blank?
      if SpecialOffer.where(id: params[:offer_id]).exists?
        @special_offer = SpecialOffer.find(params[:offer_id])
        if !params[:terms_conditions].blank?
          @special_offer.terms_conditions = params[:terms_conditions]
          @special_offer.save
              render json: {
                code: 200,
                success: true,
                message: 'Terms and condition added successfully',
                data: {
                  id: @special_offer.id,
                  terms_conditions: @special_offer.terms_conditions
                }
              }
        else
          render json: {
            code: 400,
            success: false,
            message: "terms_conditions cant be blank" ,
            data: nil
          }
        end
      else
        render json: {
          code: 400,
          success: false,
          message: "Special Offer doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "offer_id is required" ,
        data: nil
      }
    end
  end

  def ambassador_rate
    if !params[:offer_id].blank?
      if SpecialOffer.where(id: params[:offer_id]).exists?
        @special_offer = SpecialOffer.find(params[:offer_id])
        if !params[:ambassador_rate].blank?
          @special_offer.ambassador_rate = params[:ambassador_rate]
          @special_offer.save
              render json: {
                code: 200,
                success: true,
                message: 'Ambassador rate added successfully',
                data: {
                  id: @special_offer.id,
                  ambassador_rate: @special_offer.ambassador_rate
                }
              }
        else
          render json: {
            code: 400,
            success: false,
            message: "ambassador_rate cant be blank" ,
            data: nil
          }
        end
      else
        render json: {
          code: 400,
          success: false,
          message: "Special Offer doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "offer_id is required" ,
        data: nil
      }
    end
  end

  def publish_offer
    if !params[:offer_id].blank?
      if SpecialOffer.where(id: params[:offer_id]).exists?
        @special_offer = SpecialOffer.find(params[:offer_id])
        @special_offer.status = "active"
        @special_offer.save

          if !request_user.followers.blank?
            @pubnub = Pubnub.new(
              publish_key: ENV['PUBLISH_KEY'],
              subscribe_key: ENV['SUBSCRIBE_KEY'],
              uuid: @username
              )
            request_user.followers.each do |follower|
             if follower.special_offers_notifications_setting.is_on == true
                if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " created new special offer '#{@special_offer.title}'.", notifiable: @special_offer, resource: @special_offer, url: "/admin/events/#{@special_offer.id}", notification_type: 'mobile', action_type: 'create_offer')
                  @current_push_token = @pubnub.add_channels_to_push(
                   push_token: follower.device_token,
                   type: 'gcm',
                   add: follower.device_token
                   ).value

                   payload = {
                    "pn_gcm":{
                     "notification":{
                       "title": get_full_name(request_user),
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
                   channel: follower.device_token,
                   message: payload
                   ) do |envelope|
                       puts envelope.status
                  end
                 end # notificatiob end
                end #special offer setting end
            end #each
          end # not blank
            render json: {
              code: 200,
              success: true,
              message: 'SpecialOffer successfully published',
              data: {
                id: @special_offer.id,
                image: @special_offer.image,
                title: @special_offer.title,
                description: @special_offer.description,
                over_18: @special_offer.over_18,
                limited: @special_offer.limited,
                quantity: @special_offer.quantity,
                start_time: @special_offer.start_time,
                end_time: @special_offer.end_time,
                terms_conditions: @special_offer.terms_conditions,
                ambassador_rate: @special_offer.ambassador_rate,
                status: @special_offer.status,
                outlets: @special_offer.outlets.map { |e| {id: e.id, outlet_address: jsonify_location(e.outlet_address)}}
                
              }
            }
      else
        render json: {
          code: 400,
          success: false,
          message: "Special Offer doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "offer_id is required" ,
        data: nil
      }
    end
  end

#   def create
#     @special_offer = request_user.special_offers.new
#     @special_offer.title = params[:title]
#     @special_offer.sub_title = params[:sub_title]
#     @special_offer.description = params[:description]
#     @special_offer.end_time = params[:end_time]
#     @special_offer.date = params[:date]
#     @special_offer.time = params[:time]
#     @special_offer.validity = params[:validity]
#     @special_offer.ambassador_rate = params[:ambassador_rate]
#     @special_offer.image = params[:image]
#     @special_offer.qr_code = generate_code
#     @special_offer.terms_conditions = params[:terms_conditions]
#     if !params[:location].blank?
#       @special_offer.location = params[:location][:name]
#       @special_offer.lat = params[:location][:geometry][:lat]
#       @special_offer.lng = params[:location][:geometry][:lng]
#     end

#     if @special_offer.save
#      # create_activity(request_user, "created special offer", @special_offer, "SpecialOffer", admin_special_offer_path(@special_offer),@special_offer.title, 'post', 'created_special_offer')
#       if !request_user.followers.blank?
#         @pubnub = Pubnub.new(
#           publish_key: ENV['PUBLISH_KEY'],
#           subscribe_key: ENV['SUBSCRIBE_KEY'],
#           uuid: @username
#           )
#       request_user.followers.each do |follower|
#    if follower.special_offers_notifications_setting.is_on == true
#       if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " created new special offer '#{@special_offer.title}'.", notifiable: @special_offer, resource: @special_offer, url: "/admin/events/#{@special_offer.id}", notification_type: 'mobile', action_type: 'create_offer')
#         @current_push_token = @pubnub.add_channels_to_push(
#          push_token: follower.device_token,
#          type: 'gcm',
#          add: follower.device_token
#          ).value

#          payload = {
#           "pn_gcm":{
#            "notification":{
#              "title": get_full_name(request_user),
#              "body": @notification.action
#            },
#            data: {
#             "id": @notification.id,
#             "actor_id": @notification.actor_id,
#             "actor_image": @notification.actor.avatar,
#             "notifiable_id": @notification.notifiable_id,
#             "notifiable_type": @notification.notifiable_type,
#             "action": @notification.action,
#             "action_type": @notification.action_type,
#             "created_at": @notification.created_at,
#             "body": ''
#            }
#           }
#          }

#        @pubnub.publish(
#          channel: follower.device_token,
#          message: payload
#          ) do |envelope|
#              puts envelope.status
#         end
#        end # notificatiob end
#       end #special offer setting end
#       end #each
#       end # not blank
#       render json: {
#         code: 200,
#         success: true,
#         message: 'Special offer created successfully.',
#         data: nil
#       }

#     else
#       render json: {
#         code: 400,
#         success: false,
#         message: @special_offer.errors.full_messages,
#         data: nil

#       }
#     end
# end

 def destroy
  if !params[:offer_id].blank?
    if SpecialOffer.where(id: params[:offer_id]).exists?
      @special_offer = SpecialOffer.find(params[:offer_id])
      if @special_offer.destroy
        render json: {
          code: 200,
          success: true,
          message: 'Special offer successfully deleted.',
          data: nil
        }
      else
        render json:  {
          code: 400,
          success: false,
          message: 'Special offer deletion failed.',
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "special_offer doesnt exist",
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "offer_id is required",
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

  def get_redeem_count(offer)
     if offer.redemptions
       offer.redemptions.size
     else
      0
     end
  end



end


