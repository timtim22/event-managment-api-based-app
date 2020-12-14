class Api::V1::ForwardingController < Api::V1::ApiMasterController
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


        @offer_forward = OfferForwarding.create!(user_id: request_user.id, is_ambassador: request_user.profile.is_ambassador, recipient_id: id, offer_type:params[:offer_type], offer_id: params[:offer_id])

       if notification = Notification.create!(recipient: @recipient, actor: request_user, action: get_full_name(request_user) + " has sent you #{term + @offer.title}", notifiable: @offer,resource: @offer_forward, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "#{to_underscore_case(@offer.class.name)}_forwarded")


       # create_activity(request_user, "forwarded '#{if params[:offer_type] == 'SpecialOffer' then 'special offer' else 'pass' end} '", @offer_forward, 'OfferForwarding', '', '', 'post', "forwarded_#{params[:offer_type]}")

         @current_push_token = @pubnub.add_channels_to_push(
           push_token: @recipient.profile.device_token,
           type: 'gcm',
           add: @recipient.profile.device_token
           ).value

            data = {}
            case params[:offer_type]
            when "Pass"
              data = {
                "id": notification.id,
                "pass_id": notification.resource.offer.id,
                "event_name": notification.resource.offer.event.name,
                "friend_name": User.get_full_name(notification.resource.user),
                "friend_id": notification.resource.user.id,
                "business_name": User.get_full_name(notification.resource.offer.user),
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
                "friend_name": User.get_full_name(notification.resource.user),
                "business_name": User.get_full_name(notification.resource.offer.user),
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
                "friend_name": User.get_full_name(notification.resource.user),
                "actor_image": notification.actor.avatar,
                "business_name": User.get_full_name(notification.resource.offer.user),
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
            channel: [@recipient.profile.device_token],
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


          @offer_share = OfferShare.create!(user_id: @sender.id, is_ambassador: @sender.profile.is_ambassador, recipient_id: request_user.id, offer_type:params[:offer_type], offer_id: params[:offer_id], business: @offer.user)

          # if notification = Notification.create!(recipient: @recipient, actor: @sender, action: get_full_name(@sender) + " has shared with you #{term + @offer.title}", notifiable: @offer, resource: @offer_share, url: "/admin/users/#{@recipient.id}", notification_type: 'mobile', action_type: "#{to_underscore_case(@offer.class.name)}_shared")



          #   @current_push_token = @pubnub.add_channels_to_push(
          #     push_token: @recipient.profile.device_token,
          #     type: 'gcm',
          #     add: @recipient.profile.device_token
          #     ).value


          #     data = {}
          #     case params[:offer_type]
          #     when "Pass"
          #       data = {
          #         "id": notification.id,
          #         "pass_id": notification.resource.offer.id,
          #         "event_name": notification.resource.offer.event.name,
          #         "friend_name": User.get_full_name(notification.resource.user),
          #         "friend_id": notification.resource.user.id,
          #         "business_name": User.get_full_name(notification.resource.offer.user),
          #         "actor_image": notification.actor.avatar,
          #         "notifiable_id": notification.notifiable_id,
          #         "notifiable_type": notification.notifiable_type,
          #         "action": notification.action,
          #         "action_type": notification.action_type,
          #         "created_at": notification.created_at,
          #         "is_read": !notification.read_at.nil?
          #       }
          #     when "SpecialOffer"
          #       data = {
          #         "id": notification.id,
          #         "special_offer_id": notification.resource.offer.id,
          #         "special_offer_title": notification.resource.offer.title,
          #         "friend_name": User.get_full_name(notification.resource.user),
          #         "business_name": User.get_full_name(notification.resource.offer.user),
          #         "actor_image": notification.actor.avatar,
          #         "notifiable_id": notification.notifiable_id,
          #         "notifiable_type": notification.notifiable_type,
          #         "action": notification.action,
          #         "action_type": notification.action_type,
          #         "created_at": notification.created_at,
          #         "is_read": !notification.read_at.nil?
          #       }
          #     when "Competition"
          #       data = {
          #         "id": notification.id,
          #         "competition_id": notification.resource.offer.id,
          #         "competition_name": notification.resource.offer.title,
          #         "friend_name": User.get_full_name(notification.resource.user),
          #         "actor_image": notification.actor.avatar,
          #         "business_name": User.get_full_name(notification.resource.offer.user),
          #         "notifiable_id": notification.notifiable_id,
          #         "notifiable_type": notification.notifiable_type,
          #         "action": notification.action,
          #         "action_type": notification.action_type,
          #         "created_at": notification.created_at,
          #         "is_read": !notification.read_at.nil?
          #       }
          #     end

          #    payload = {
          #    "pn_gcm":{
          #      "notification":{
          #        "title": get_full_name(request_user),
          #        "body": notification.action
          #      },
          #      data: data
          #    }
          #  }

          #    @pubnub.publish(
          #      channel: [@recipient.profile.device_token],
          #      message: payload
          #       ) do |envelope|
          #         puts envelope.status
          #       end
          #   end ##notification create

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

  api :POST, '/api/v1/events/forward', 'To forward an event'
  # param :event_id, :number, :desc => "Event ID", :required => true
  # param :user_ids, :number, :desc => "User IDs (1,2,3)", :required => true

  def forward_event
    if !params[:event_id].blank? && !params[:user_ids].blank?
      ids_array = params[:user_ids].split(',').map {|s| s.to_i } # convert into array

          @event = Event.find(params[:event_id])
          @already_shared = []
       success = false
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
       @channel = "event"
       if ids_array.kind_of?(Array)
       ids_array.each do |id|
       @check = EventForwarding.where(event_id: @event.id).where(recipient_id: id).where(user_id: request_user.id).first
        @recipient = User.find(id)
       if @check.blank?

       @event_forward = EventForwarding.create!(user_id: request_user.id, recipient_id: id, event_id: params[:event_id])

       if notification = Notification.create!(recipient: @recipient, actor: request_user, action: get_full_name(request_user) + " has forwarded you and event.", notifiable: @event, resource: @event, resource: @event_forward, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: "event_forwarded")



        #create_activity(request_user, "forwarded event", @event_forward, 'EventForwarding', '', '', 'post','forward_event')

         @current_push_token = @pubnub.add_channels_to_push(
           push_token: @recipient.profile.device_token,
           type: 'gcm',
           add: @recipient.profile.device_token
           ).value

          payload = {
          "pn_gcm":{
            "notification":{
              "title": get_full_name(request_user),
              "body": notification.action
            },
            data: {
              "id": notification.id,
              "event_id": notification.resource.event.id,
              "friend_name": User.get_full_name(notification.resource.user),
              "friend_id": notification.resource.user.id,
              "event_name": notification.resource.event.name,
              "event_start_date": notification.resource.event.start_date,
              "event_location": notification.resource.event.location,
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
            channel: [@recipient.profile.device_token],
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

<<<<<<< HEAD
  api :POST, '/api/v1/events/share', 'To share an event via link'
 # param :event_id, :number, :desc => "Event ID", :required => true
 # param :event_shared, String, :desc => "True/False", :required => true
 # param :sender_token, String, :desc => "Sender Token", :required => true
=======
  # api :POST, '/api/v1/events/share', 'To share an event via link'
  # param :event_id, :number, :desc => "Event ID", :required => true
  # param :event_shared, String, :desc => "True/False", :required => true
  # param :sender_token, String, :desc => "Sender Token", :required => true
>>>>>>> 4b30fc252dddcf2a03470e7f084916f682d88412

   def share_event
    if !params[:event_shared].blank? && params[:event_shared] ==  'true'
      if !params[:sender_token].blank? && !params[:event_id].blank?
        @sender = get_user_from_token(params[:sender_token])

        @event = Event.find(params[:event_id])

        @check = EventShare.where(event_id: @event.id).where(recipient_id: request_user.id).where(user_id: @sender.id).first
        if @check.blank?
        @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
          )

          @recipient = request_user
          @event_share = EventShare.create!(user_id: @sender.id, recipient_id: request_user.id, event_id: params[:event_id])

          # if @notification = Notification.create!(recipient: @recipient, actor: @sender, action: get_full_name(@sender) + " shared an event with you.", notifiable: @event, resource: @event, url: "/admin/events/#{@event.id}", notification_type: 'mobile', action_type: "share_event")



          #   @current_push_token = @pubnub.add_channels_to_push(
          #     push_token: @recipient.profile.device_token,
          #     type: 'gcm',
          #     add: @recipient.profile.device_token
          #     ).value

          #    payload = {
          #    "pn_gcm":{
          #      "notification":{
          #        "title": get_full_name(request_user),
          #        "body": @notification.action
          #      },
          #      data: {
          #        "id": @notification.id,
          #        "actor_id": @notification.actor_id,
          #        "actor_image": @notification.actor.avatar,
          #        "notifiable_id": @notification.notifiable_id,
          #        "notifiable_type": @notification.notifiable_type,
          #        "action_type": @notification.action_type,
          #        "offer": @offer,
          #        "action": @notification.action,
          #        "created_at": @notification.created_at,
          #        "body": ''
          #      }
          #    }
          #  }

          #    @pubnub.publish(
          #      channel: [@recipient.profile.device_token],
          #      message: payload
          #       ) do |envelope|
          #         puts envelope.status
          #       end
          #   end ##notification create

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

end
