class Api::V1::Share::ForwardingController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def forward_offer
    if !params[:offer_id].blank? && !params[:offer_type].blank? && !params[:user_ids].blank?
      ids_array = params[:user_ids].split(',').map {|s| s.to_i } # convert into array
        if params[:offer_type] == 'Pass'
          @offer = Pass.find(params[:offer_id])
        elsif params[:offer_type] == 'SpecialOffer'
          @offer = SpecialOffer.find(params[:offer_id])
        elsif params[:offer_type] == 'Competition'
          @offer = Competition.find(params[:offer_id])
        end

        @already_shared = []

       success = false
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )

       if ids_array.kind_of?(Array)
       ids_array.each do |id|
       @check = OfferForwarding.where(offer_id: @offer.id).where(recipient_id: id).where(user_id: request_user.id).where(offer_type: params[:offer_type]).first
       @recipient = User.find(id)
       if @check.blank?
        term = ''
        case params[:offer_type]
        when "Pass"
          term = 'a pass '
        when "SpecialOffer"
          term = 'a Special Offer '
        when "Competition"
          term = 'a Competition '
        end


        @offer_forward = OfferForwarding.create!(user_id: request_user.id, is_ambassador: is_ambassador?(request_user), recipient_id: id, offer_type:params[:offer_type], offer_id: params[:offer_id])

       if notification = Notification.create!(recipient: @recipient, actor: request_user, action: get_full_name(request_user) + " has sent you #{term + @offer.title}", notifiable: @offer,resource: @offer_forward, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "#{to_underscore_case(@offer.class.name)}_forwarded")


       # create_activity(request_user, "forwarded '#{if params[:offer_type] == 'SpecialOffer' then 'special offer' else 'pass' end} '", @offer_forward, 'OfferForwarding', '', '', 'post', "forwarded_#{params[:offer_type]}")

         @current_push_token = @pubnub.add_channels_to_push(
           push_token: @recipient.device_token,
           type: 'gcm',
           add: @recipient.device_token
           ).value

            data = {}
            case params[:offer_type]
            when "Pass"
              data = {
                "id": notification.id,
                "pass_id": notification.resource.offer.id,
                "event_name": notification.resource.offer.event.title,
                "friend_name": get_full_name(notification.resource.user),
                "friend_id": notification.resource.user.id,
                "business_name": get_full_name(notification.resource.offer.user),
                "actor_image": notification.actor.avatar,
                "notifiable_id": notification.notifiable_id,
                "notifiable_type": notification.notifiable_type,
                "action": notification.action,
                "action_type": notification.action_type,
                "created_at": notification.created_at,
                "is_read": !notification.read_at.nil?
              }
            when "SpecialOffer"
              data = {
                "id": notification.id,
                "special_offer_id": notification.resource.offer.id,
                "special_offer_title": notification.resource.offer.title,
                "friend_name": get_full_name(notification.resource.user),
                "business_name": get_full_name(notification.resource.offer.user),
                "actor_image": notification.actor.avatar,
                "notifiable_id": notification.notifiable_id,
                "notifiable_type": notification.notifiable_type,
                "action": notification.action,
                "action_type": notification.action_type,
                "created_at": notification.created_at,
                "is_read": !notification.read_at.nil?
              }
            when "Competition"
              data = {
                "id": notification.id,
                "competition_id": notification.resource.offer.id,
                "competition_name": notification.resource.offer.title,
                "friend_name": get_full_name(notification.resource.user),
                "actor_image": notification.actor.avatar,
                "business_name": get_full_name(notification.resource.offer.user),
                "notifiable_id": notification.notifiable_id,
                "notifiable_type": notification.notifiable_type,
                "action": notification.action,
                "action_type": notification.action_type,
                "created_at": notification.created_at,
                "is_read": !notification.read_at.nil?
              }
            end

          payload = {
          "pn_gcm":{
            "notification":{
              "title": get_full_name(request_user),
              "body": notification.action
            },
            data: data
          }
        }

          @pubnub.publish(
            channel: [@recipient.device_token],
            message: payload
             ) do |envelope|
               puts envelope.status
           end
           success = true
           else
           success = false
         end ##notification create
        else
          @already_shared.push(@recipient)
        end
      end#each

    if @already_shared.size != ids_array.size
        render json: {
             code: 200,
             success: true,
             message: 'Notification sent successfully.',
             data: nil
           }
      else
        render json: {
          code: 400,
          success: false,
          message: 'You have already forwarded this offer.',
          data: nil
        }
      end
    else
      render json:  {
        code: 400,
        success: false,
        message: 'user_ids should be in format like "1,2,3,4"',
        data: nil
      }
    end

    else
      render json:  {
        code: 400,
        success: false,
        message: 'offer_id, offer_type and user_ids are required fields',
        ids: params[:user_ids],
        data: nil
      }
    end
   end


   

   def share_offer
    if !params[:offer_shared].blank? && params[:offer_shared] ==  'true'
      if !params[:sender_token].blank? && !params[:offer_id].blank? && !params[:offer_type].blank?
        @sender = get_user_from_token(params[:sender_token])
        if params[:offer_type] == 'Pass'
          @offer = Pass.find(params[:offer_id])
        elsif params[:offer_type] == 'SpecialOffer'
          @offer = SpecialOffer.find(params[:offer_id])
        elsif params[:offer_type] == 'Competition'
          @offer = Competition.find(params[:offer_id])
        end

        @already_shared = []

        @check = OfferShare.where(offer_id: @offer.id).where(recipient_id: request_user.id).where(user_id: @sender.id).first

        if @check.blank?
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
          )

          @recipient = request_user

          term = ''
          case params[:offer_type]
          when "Pass"
            term = 'a pass '
          when "SpecialOffer"
            term = 'a Special Offer '
          when "Competition"
            term = 'a Competition '
          end


          @offer_share = OfferShare.create!(user_id: @sender.id, is_ambassador: is_ambassador?(@sender), recipient_id: request_user.id, offer_type:params[:offer_type], offer_id: params[:offer_id], business: @offer.user)

          if notification = Notification.create!(recipient: @recipient, actor: @sender, action: get_full_name(@sender) + " has shared with you #{term + @offer.title}", notifiable: @offer, resource: @offer_share, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "#{to_underscore_case(@offer.class.name)}_shared")



            @current_push_token = @pubnub.add_channels_to_push(
              push_token: @recipient.device_token,
              type: 'gcm',
              add: @recipient.device_token
              ).value


              data = {}
              case params[:offer_type]
              when "Pass"
                data = {
                  "id": notification.id,
                  "pass_id": notification.resource.offer.id,
                  "event_name": notification.resource.offer.event.title,
                  "friend_name": get_full_name(notification.resource.user),
                  "friend_id": notification.resource.user.id,
                  "business_name": get_full_name(notification.resource.offer.user),
                  "actor_image": notification.actor.avatar,
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                }
              when "SpecialOffer"
                data = {
                  "id": notification.id,
                  "special_offer_id": notification.resource.offer.id,
                  "special_offer_title": notification.resource.offer.title,
                  "friend_name": get_full_name(notification.resource.user),
                  "business_name": get_full_name(notification.resource.offer.user),
                  "actor_image": notification.actor.avatar,
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                }
              when "Competition"
                data = {
                  "id": notification.id,
                  "competition_id": notification.resource.offer.id,
                  "competition_name": notification.resource.offer.title,
                  "friend_name": get_full_name(notification.resource.user),
                  "actor_image": notification.actor.avatar,
                  "business_name": get_full_name(notification.resource.offer.user),
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                }
              end

             payload = {
             "pn_gcm":{
               "notification":{
                 "title": get_full_name(request_user),
                 "body": notification.action
               },
               data: data
             }
           }

             @pubnub.publish(
               channel: [@recipient.device_token],
               message: payload
                ) do |envelope|
                  puts envelope.status
                end
            end ##notification create

            render json: {
              code: 200,
              success: true,
              message: 'offered shared successfully.',
              data:nil
            }
          else
            render json: {
              code: 400,
              success: false,
              message: 'offer is already shared.',
              data: nil
            }
          end

      else
       render json: {
         code: 400,
         success: false,
         message: 'sender_token, offer_id, offer_type are required fields',
         data: nil
       }
      end
    end

   end

  ################################# Event ##########################################33

  api :POST, '/api/v1/share/forward-event', 'To forward an event'
  # param :event_id, :number, :desc => "Event ID", :required => true
  # param :user_ids, :number, :desc => "User IDs (1,2,3)", :required => true

  def forward_event
    if !params[:event_id].blank? && !params[:user_ids].blank?
      ids_array = params[:user_ids].split(',').map {|s| s.to_i } # convert into array

          @event = ChildEvent.find(params[:event_id])
          @already_shared = []
       success = false
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
       @channel = "event"
       if ids_array.kind_of?(Array)
       ids_array.each do |id|
       @check = EventForwarding.where(child_event_id: @event.id).where(recipient_id: id).where(user_id: request_user.id).first
        @recipient = User.find(id)
       if @check.blank?

       @event_forward = EventForwarding.create!(user_id: request_user.id, recipient_id: id, child_event: @event )

       if notification = Notification.create!(recipient: @recipient, actor: request_user, action: get_full_name(request_user) + " has forwarded you and event.", notifiable: @event, resource: @event, resource: @event_forward, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: "event_forwarded")



        #create_activity(request_user, "forwarded event", @event_forward, 'EventForwarding', '', '', 'post','forward_event')

         @current_push_token = @pubnub.add_channels_to_push(
           push_token: @recipient.device_token,
           type: 'gcm',
           add: @recipient.device_token
           ).value

          payload = {
          "pn_gcm":{
            "notification":{
              "title": get_full_name(request_user),
              "body": notification.action
            },
            data: {
              "id": notification.id,
              "event_id": notification.resource.child_event.id,
              "friend_name": get_full_name(notification.resource.user),
              "friend_id": notification.resource.user.id,
              "event_name": notification.resource.child_event.title,
              "event_start_date": notification.resource.child_event.start_time,
              "event_location": jsonify_location(notification.resource.child_event.location),
              "actor_image": notification.actor.avatar,
              "notifiable_id": notification.notifiable_id,
              "notifiable_type": notification.notifiable_type,
              "action": notification.action,
              "action_type": notification.action_type,
              "created_at": notification.created_at,
              "is_read": !notification.read_at.nil?
            }
          }
        }

          @pubnub.publish(
            channel: [@recipient.device_token],
            message: payload
             ) do |envelope|
               puts envelope.status
           end
           success = true
           else
           success = false
         end ##notification create
        else
          @already_shared.push(@recipient)
        end
      end#each

      if @already_shared.size != ids_array.size
        render json: {
             code: 200,
             success: true,
             message: 'Event forwarded successfully.',
             data: nil
           }
      else
        render json: {
          code: 400,
          success: false,
          message: 'You have already forwarded event to this user .',
          data: nil
        }
      end
    else
      render json:  {
        code: 400,
        success: false,
        message: 'user_ids should be in format like "1,2,3,4"',
        data: nil
      }
    end

    else
      render json:  {
        code: 400,
        success: false,
        message: 'event_id and user_ids are required fields',
        ids: params[:user_ids],
        data: nil
      }
    end
   end


   def share_event
    if !params[:event_shared].blank? && params[:event_shared] ==  'true'
      if !params[:sender_token].blank? && !params[:event_id].blank?
        @sender = get_user_from_token(params[:sender_token])

        @event = ChildEvent.find(params[:event_id])

        @check = EventShare.where(event_id: @event.id).where(recipient_id: request_user.id).where(user_id: @sender.id).first
        if @check.blank?
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
          )

          @recipient = request_user
          @event_share = EventShare.create!(user_id: @sender.id, recipient_id: request_user.id, child_event_id: params[:event_id])


          if notification = Notification.create!(recipient: @recipient, actor: @sender, action: get_full_name(@sender) + " shared an event with you.", notifiable: @event, resource: @event_share, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: "event_shared")


            @current_push_token = @pubnub.add_channels_to_push(
              push_token: @recipient.device_token,
              type: 'gcm',
              add: @recipient.device_token
              ).value

             payload = {
             "pn_gcm":{
               "notification":{
                 "title": get_full_name(request_user),
                 "body": notification.action
               },
               data: {
                "id": notification.id,
                "actor_id": notification.actor_id,
                "actor_image": notification.actor.avatar,
                "notifiable_id": notification.notifiable_id,
                "notifiable_type": notification.notifiable_type,
                "action": notification.action,
                "action_type": notification.action_type,
                "location": location,
                "created_at": notification.created_at,
                "is_read": !notification.read_at.nil?,
                "business_name": get_full_name(notification.resource.child_event.user),
                "event_name": notification.resource.event.title,
                "event_id": notification.resource.event.id,
                "event_location": jsonify_location(notification.resource.event.location),
                "event_start_date": notification.resource.event.start_time,
                "friend_name": get_full_name(notification.resource.user)
               }
             }
           }

             @pubnub.publish(
               channel: [@recipient.device_token],
               message: payload
                ) do |envelope|
                  puts envelope.status
                end
            end ##notification create

            render json: {
              code: 200,
              success: true,
              message: 'Event shared successfully.',
              data:nil
            }
          else
            render json: {
              code: 400,
              success: false,
              message: 'Event is already shared.',
              data: nil
            }
          end

      else
       render json: {
         code: 400,
         success: false,
         message: 'sender_token and event_id are required fields',
         data: nil
       }
      end

    end
   end




   api :POST, '/api/v1/ask-location', 'Ask for target user location'
  #param :askee_ids, :number, :desc => "askee_ids(1,2,3)", :required => true

  def ask_location
    if !params[:askee_ids].blank?
      askee_ids_array = params[:askee_ids].split(',').map {|s| s.to_i }
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
      @success = false
      askee_ids_array.each do |id|

      @askee = User.find(id)
      if notification = Notification.create!(recipient: @askee, actor: request_user, action: get_full_name(request_user) + " is asking for your current location.", notifiable: @askee, url: "/admin/users/#{@askee.id}", resource: @askee, notification_type: 'mobile',action_type: 'ask_location')
        @location_request = LocationRequest.create!(user_id: request_user.id, askee_id: id, notification_id: notification.id)
        @current_push_token = @pubnub.add_channels_to_push(
          push_token: @askee.device_token,
          type: 'gcm',
          add: @askee.device_token
          ).value


          payload = {
            "pn_gcm":{
              "notification":{
                "title": get_full_name(request_user),
                "body": notification.action
              },
              data: {
                "id": notification.id,
                "friend_name": get_full_name(notification.actor),
                "friend_id": notification.actor.id,
                "actor_image": notification.actor.avatar,
                "notifiable_id": notification.notifiable_id,
                "notifiable_type": notification.notifiable_type,
                "action": notification.action,
                "action_type": notification.action_type,
                "created_at": notification.created_at,
                "is_read": !notification.read_at.nil?
              }
            }
          }

          @pubnub.publish(
            channel: [@askee.device_token],
            message: payload
             ) do |envelope|
               puts envelope.status
           end

           @success = true
          else
            @success = false
        end ##notification create
      end # each
        if @success
          render json:  {
            code: 200,
            success: true,
            message: "Notification sent successfully.",
            data: nil
          }
        else
          render json:  {
            code: 400,
            success: false,
            message: "Notification was not sent.",
            data: nil
          }
        end
        else
          render json:  {
            code: 400,
            success: false,
            message: "askee_ids are required.",
            data: nil
          }
        end
     end





  api :POST, '/api/v1/get-location', 'Get location of the target user'
  #param :askee_ids, :number, :desc => "askee_ids(1,2,3)", :required => true

     def get_location
      if !params[:lat].blank? && !params[:lng].blank? && !params[:asker_id].blank?
       location = {}
       location['lat'] = params[:lat]
       location['lng'] = params[:lng]
       @asker = User.find(params[:asker_id])
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
      if @notification = Notification.create(recipient: @asker, actor: request_user, action: get_full_name(request_user) + " has sent you #{if request_user.gender ==  'male' then 'his' else 'her' end } current location.", notifiable: @askee, resource: @askee,url: "/admin/users/#{@asker.id}", notification_type: 'mobile', action_type: 'get_location')

        @current_push_token = @pubnub.add_channels_to_push(
          push_token: @asker.device_token,
          type: 'gcm',
          add: @asker.device_token
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
            channel: @asker.device_token,
            message: payload
            ) do |envelope|
                puts envelope.status
           end

           render json: {
            code: 200,
            success: true,
            message: 'Notification sent successfully.',
            data: nil
          }
          else
            render json: {
              code: 400,
              success: false,
              message: 'Notification was not sent, please try again later.',
              data: nil
            }

        end ##notification create
      else
        render json:  {
          code: 400,
          success: false,
          message: "asker_id, lat and lng is required.",
          data: nil
        }
      end
     end


     

       api :POST, '/api/v1/share/send-location', 'Send location to list of users'
       param :askee_ids, :number, :desc => "askee_ids(1,2,3)", :required => true
       

     def send_location
      if !params[:lat].blank? && !params[:lng].blank? && !params[:user_ids].blank?
         ids_array = params[:user_ids].split(',').map {|s| s.to_i } # convert into array
         location = {}
         location['lat'] = params[:lat]
         location['lng'] = params[:lng]
         success = false
         @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
          )

         if ids_array.kind_of?(Array)
         ids_array.each do |id|

          @recipient = User.find(id)
         if notification = Notification.create!(recipient: @recipient, actor: request_user, action: get_full_name(request_user) + " has sent you #{if request_user.profile.gender ==  'male' then 'his' else 'her' end } current location.", notifiable: @recipient, resource: @recipient, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "send_location")

          @location_share = LocationShare.create!(user_id: request_user.id, recipient_id: id, lat:params[:lat], lng: params[:lng], notification_id: notification.id)

           @current_push_token = @pubnub.add_channels_to_push(
             push_token: @recipient.device_token,
             type: 'gcm',
             add: @recipient.device_token
             ).value

            payload = {
            "pn_gcm":{
              "notification":{
                "title": get_full_name(request_user),
                "body": notification.action
              },
              data: {
                "id": notification.id,
                "friend_name": get_full_name(notification.actor),
                "friend_id": notification.actor.id,
                "actor_image": notification.actor.avatar,
                "notifiable_id": notification.notifiable_id,
                "notifiable_type": notification.notifiable_type,
                "action": notification.action,
                "action_type": notification.action_type,
                "created_at": notification.created_at,
                "is_read": !notification.read_at.nil?,
                "location": location
              }
            }
          }

            @pubnub.publish(
              channel: [@recipient.device_token],
              message: payload
               ) do |envelope|
                 puts envelope.status
             end
             success = true
             else
             success = false
           end ##notification create
        end#each

        if success
          render json: {
               code: 200,
               success: true,
               message: 'Notification sent successfully.',
               data: nil
             }
        else
          render json: {
            code: 400,
            success: false,
            message: 'Notification was not sent, please try again later.',
            data: nil
          }
        end
      else
        render json:  {
          code: 400,
          success: false,
          message: 'user_ids should be in format like "1,2,3,4"',
          data: nil
        }
      end

      else
        render json:  {
          code: 400,
          success: false,
          message: 'lat, lng and user_ids are required fields',
          ids: params[:user_ids],
          data: nil
        }
      end
     end

end
