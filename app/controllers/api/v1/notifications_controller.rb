class Api::V1::NotificationsController < Api::V1::ApiMasterController
  before_action :authorize_request
  require 'json'
  require 'pubnub'
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  api :get, '/api/v1/notifications/get-notifications', 'Get notifications list - logged IN user'

  def index
    @notifications = []
    notifications = request_user.notifications.order(id: 'DESC').page(params[:page]).per(10)
    notifications.each do |notification|
      location = {}
      location['lat'] = if !notification.location_share.blank? then notification.location_share.lat else '' end
      location['lng'] = if !notification.location_share.blank? then notification.location_share.lng else '' end

      case notification.action_type
      when "create_event"
        @notifications << {
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
          "business_name": User.get_full_name(notification.resource.user),
          "event_name": notification.resource.name,
          "event_id": notification.resource.id,
          "event_location": eval(notification.resource.location)["city"] + ", " + eval(notification.resource.location)["country"],
          "event_start_date": notification.resource.start_date
        }

      when "create_competition"
          @notifications << {
            "id": notification.id,
            "competition_id": notification.resource.id,
            "actor_id": notification.actor_id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "location": location,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "competition_name": notification.resource.title,
            "business_name": User.get_full_name(notification.resource.user),
            "draw_date": notification.resource.validity.strftime(get_time_format),
            "is_added_to_wallet": added_to_wallet?(request_user, notification.resource.offer)

          }
        when "create_offer"
          @notifications << {
            "id": notification.id,
            "special_offer_id": notification.resource.id,
            "business_name": User.get_full_name(notification.resource.user),
            "special_offer_title": notification.resource.title,
            "actor_id": notification.actor_id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "location": location,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "is_added_to_wallet": added_to_wallet?(request_user, notification.resource.offer)
          }

        # when "update_special_offer"
        #   @notifications << {
        #     "special_offers_id": notification.id,
        #     "business_name": User.get_full_name(notification.resource.user),
        #     "special_offer_name": notification.resource.title,
        #     "actor_id": notification.actor_id,
        #     "actor_image": notification.actor.avatar,
        #     "notifiable_id": notification.notifiable_id,
        #     "notifiable_type": notification.notifiable_type,
        #     "action": notification.action,
        #     "action_type": notification.action_type,
        #     "location": location,
        #     "created_at": notification.created_at,
        #     "is_read": !notification.read_at.nil?

        #   }

        when "create_pass"
          @notifications << {
            "id": notification.id,
            "pass_id": notification.resource.id,
            "business_name": User.get_full_name(notification.resource.user),
            "event_name": notification.resource.event.name,
            "event_location": eval(notification.resource.event.location)["city"] + ", " + eval(notification.resource.event.location)["country"],
            "event_end_date": notification.resource.event.end_date,
            "actor_id": notification.actor_id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "location": location,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
          "is_added_to_wallet": added_to_wallet?(request_user, notification.resource.offer)

          }
        when "create_interest"
          @notifications << {
            "id": notification.id,
            "business_name": User.get_full_name(notification.resource.child_event.user),
            "friend_name": User.get_full_name(notification.resource.user),
            "event_name": notification.resource.child_event.name,
            "event_id": notification.resource.child_event.id,
            "event_start_date": notification.resource.child_event.start_date,
            "event_location": eval(notification.resource.child_event.location)["city"] + ", " + eval(notification.resource.child_event.location)["country"],
            "actor_id": notification.actor_id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "interest_level": notification.resource.level
          }

        when "create_going"
          @notifications << {
            "id": notification.id,
            "business_name": User.get_full_name(notification.resource.child_event.user),
            "friend_name": User.get_full_name(notification.resource.user),
            "event_name": notification.resource.child_event.name,
            "event_id": notification.resource.child_event.id,
            "event_start_date": notification.resource.child_event.start_date,
            "event_location": eval(notification.resource.child_event.location)["city"] + ", " + eval(notification.resource.child_event.location)["country"], 
            "actor_id": notification.actor_id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "interest_level": notification.resource.level
          }

        when "comment"
          @notifications << {
            "id": notification.id,
            "user_name": User.get_full_name(notification.resource.user),
            "comment": notification.resource.comment,
            "event_name": notification.resource.child_event.name,
            "user_id": notification.resource.user.id,
            "event_id": notification.resource.child_event.id,
            "actor_id": notification.actor_id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "last_comment": notification.resource.comment,
            "comment_id": notification.resource.id,
            "is_host": is_business?(notification.resource.user)
          }

        when "reply_comment"
          @notifications << {
            "id": notification.id,
            "event_id": notification.resource.comment.child_event.id,
            "event_name": notification.resource.comment.child_event.name,
            "replier_id": notification.resource.user.id,
            "replier_name": User.get_full_name(notification.resource.user),
            "comment_id": notification.resource.comment.id,
            "comment": notification.resource.comment.comment,
            "actor_id": notification.actor_id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "last_comment": notification.resource,
            "reply_id": notification.resource.id,
            "is_host": is_business?(notification.resource.user)
          }

      when "add_Competition_to_wallet"
        @notifications << {
          "id": notification.id,
          "friend_name": User.get_full_name(notification.resource.user),
          "business_name": User.get_full_name(notification.resource.offer.user),
          "competition_id": notification.resource.offer.id,
          "competition_name": notification.resource.offer.title,
          "competition_host": User.get_full_name(notification.resource.offer.user),
          "competition_draw_date": notification.resource.offer.end_date,
          "user_id": notification.resource.user.id,
          "actor_image": notification.actor.avatar,
          "notifiable_id": notification.notifiable_id,
          "notifiable_type": notification.notifiable_type,
          "action": notification.action,
          "action_type": notification.action_type,
          "created_at": notification.created_at,
          "is_read": !notification.read_at.nil?,
          "is_added_to_wallet": added_to_wallet?(request_user, notification.resource.offer)
        }

        when "add_Pass_to_wallet"
          @notifications << {
            "id": notification.id,
            "friend_name": User.get_full_name(notification.resource.user),
            "event_name": notification.resource.offer.event.name,
            "event_start_date": notification.resource.offer.event.start_date,
            "pass_id": notification.resource.offer.id,
            "event_location": eval(notification.resource.offer.event.location)["city"] + ", " + eval(notification.resource.offer.event.location)["country"],
            "user_id": notification.resource.offer.user.id,
            "actor_image": notification.actor.avatar,
            "total_grabbers_count": notification.resource.offer.wallets.size,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "is_added_to_wallet": added_to_wallet?(request_user, notification.resource.offer)
          }

        when "add_SpecialOffer_to_wallet"
          @notifications << {
            "id": notification.id,
            "friend_name": User.get_full_name(notification.resource.user),
            "special_offer_id": notification.resource.offer.id,
            "special_offer_title": notification.resource.offer.title,
            "business_name": User.get_full_name(notification.resource.offer.user),
            "total_grabbers_count": notification.resource.offer.wallets.size,
            "user_id": notification.resource.user.id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "is_added_to_wallet": added_to_wallet?(request_user,notification.resource.offer)
          }


      when "send_request"
        @notifications << {
          "id": notification.id,
          "friend_name": User.get_full_name(notification.resource.user),
          "friend_id": notification.resource.user.id,
          "request_id": notification.resource.id,
          "mutual_friends_count": get_mutual_friends(request_user, notification.resource.user).size,
          "actor_image": notification.actor.avatar,
          "notifiable_id": notification.notifiable_id,
          "notifiable_type": notification.notifiable_type,
          "action": notification.action,
          "action_type": notification.action_type,
          "created_at": notification.created_at,
          "is_read": !notification.read_at.nil?
        }

      when "accept_request"
        @notifications << {
          "id": notification.id,
          "friend_name": User.get_full_name(notification.resource.friend),
          "friend_id": notification.resource.friend.id,
          "mutual_friends_count": get_mutual_friends(request_user, notification.resource.friend).size,
          "actor_image": notification.actor.avatar,
          "notifiable_id": notification.notifiable_id,
          "notifiable_type": notification.notifiable_type,
          "action": notification.action,
          "action_type": notification.action_type,
          "created_at": notification.created_at,
          "is_read": !notification.read_at.nil?
        }

      when "enter_in_competition"
        @notifications << {
          "id": notification.id,
          "friend_name": User.get_full_name(notification.resource.user),
          "competition_id": notification.resource.event.id,
          "competition_name": notification.resource.event.title,
          "business_name": User.get_full_name(notification.resource.event.user),
          "draw_date": notification.resource.event.end_date,
          "actor_image": notification.actor.avatar,
          "notifiable_id": notification.notifiable_id,
          "notifiable_type": notification.notifiable_type,
          "action": notification.action,
          "action_type": notification.action_type,
          "created_at": notification.created_at,
          "is_read": !notification.read_at.nil?
        }

      when "ask_location"
        @notifications << {
          "id": notification.id,
          "friend_name": User.get_full_name(notification.actor),
          "friend_id": notification.actor.id,
          "actor_image": notification.actor.avatar,
          "notifiable_id": notification.notifiable_id,
          "notifiable_type": notification.notifiable_type,
          "action": notification.action,
          "action_type": notification.action_type,
          "created_at": notification.created_at,
          "is_read": !notification.read_at.nil?
        }

      when "send_location"
        @notifications << {
          "id": notification.id,
          "friend_name": User.get_full_name(notification.actor),
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

      when "get_winner_and_notify"
          @notifications << {
            "id": notification.id,
            "business_name": User.get_full_name(notification.resource.user),
            "competition_name": notification.resource.title,
            "total_competition_entries": notification.resource.registrations.size,
            "winner_name": User.get_full_name(notification.notifiable.user),
            "winner_avatar": notification.notifiable.user.avatar,
            "winner_id": notification.notifiable.user.id,
            "actor_image": notification.resource.user.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "location": location,
            "competition_id": notification.resource.id,
          }

        when "become_ambassador"
          @notifications << {
            "id": notification.id,
            "business_name": User.get_full_name(notification.resource.business),
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "location": location
          }

        when "friend_become_ambassador"
          @notifications << {
          "id": notification.id,
          "friend_name": User.get_full_name(notification.resource.user),
          "friend_id": notification.resource.user.id,
          "business_name": User.get_full_name(notification.resource.business),
          "actor_image": notification.actor.avatar,
          "notifiable_id": notification.notifiable_id,
          "notifiable_type": notification.notifiable_type,
          "action": notification.action,
          "action_type": notification.action_type,
          "created_at": notification.created_at,
          "is_read": !notification.read_at.nil?,
          "location": location

          }

        when "free_event_reminder"
          @notifications << {
          "id": notification.id,
          "event_name": notification.resource.name,
          "event_id": notification.resource.id,
          "event_location": eval(notification.resource.location)["city"] + ", " + eval(notification.resource.location)["country"],
          "event_start_date": notification.resource.start_date,
          "event_start_time": notification.resource.start_time,
          "event_end_time": notification.resource.end_time,
          "event_type": notification.resource.event_type,
          "actor_image": notification.actor.avatar,
          "notifiable_id": notification.notifiable_id,
          "notifiable_type": notification.notifiable_type,
          "action": notification.action,
          "action_type": notification.action_type,
          "created_at": notification.created_at,
          "is_read": !notification.read_at.nil?
          }

        when "buy_event_reminder"
          @notifications << {
          "id": notification.id,
          "event_name": notification.resource.name,
          "event_id": notification.resource.id,
          "event_location": eval(notification.resource.location)["city"] + ", " + eval(notification.resource.location)["country"],
          "event_start_date": notification.resource.start_date,
          "event_start_time": notification.resource.start_time,
          "event_end_time": notification.resource.end_time,
          "event_type": notification.resource.event_type,
          "actor_image": notification.actor.avatar,
          "notifiable_id": notification.notifiable_id,
          "notifiable_type": notification.notifiable_type,
          "action": notification.action,
          "action_type": notification.action_type,
          "created_at": notification.created_at,
          "is_read": !notification.read_at.nil?
          }

        when "pay_at_door_event_reminder"
          @notifications << {
          "id": notification.id,
          "event_name": notification.resource.name,
          "event_id": notification.resource.id,
          "event_location": eval(notification.resource.location)["city"] + ", " + eval(notification.resource.location)["country"],
          "event_start_date": notification.resource.start_date,
          "event_start_time": notification.resource.start_time,
          "event_end_time": notification.resource.end_time,
          "event_type": notification.resource.event_type,
          "actor_image": notification.actor.avatar,
          "notifiable_id": notification.notifiable_id,
          "notifiable_type": notification.notifiable_type,
          "action": notification.action,
          "action_type": notification.action_type,
          "created_at": notification.created_at,
          "is_read": !notification.read_at.nil?
          }

        when "pass_forwarded"
          @notifications << {
            "id": notification.id,
            "pass_id": notification.resource.offer.id,
            "event_name": notification.resource.offer.event.name,
            "friend_name": User.get_full_name(notification.resource.user),
            "business_name": User.get_full_name(notification.resource.offer.user),
            "friend_id": notification.resource.user.id,
            "actor_image": notification.actor.avatar,
            "notifiable_id": notification.notifiable_id,
            "notifiable_type": notification.notifiable_type,
            "action": notification.action,
            "action_type": notification.action_type,
            "created_at": notification.created_at,
            "is_read": !notification.read_at.nil?,
            "event_start_date": notification.resource.offer.event.start_date
            }

          when "special_offer_forwarded"
            @notifications << {
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

            when "competition_forwarded"
              @notifications << {
                "id": notification.id,
                "competition_id": notification.resource.offer.id,
                "competition_name": notification.resource.offer.title,
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

              when "event_forwarded"
                @notifications << {
                  "id": notification.id,
                  "event_id": notification.resource.child_event.id,
                  "friend_name": User.get_full_name(notification.resource.user),
                  "friend_id": notification.resource.user.id,
                  "event_name": notification.resource.child_event.name,
                  "event_start_date": notification.resource.child_event.start_date,
                  "event_location": eval(notification.resource.child_event.location)["city"] + ", " + eval(notification.resource.child_event.location)["country"],
                  "actor_image": notification.actor.avatar,
                  "notifiable_id": notification.notifiable_id,
                  "notifiable_type": notification.notifiable_type,
                  "action": notification.action,
                  "action_type": notification.action_type,
                  "created_at": notification.created_at,
                  "is_read": !notification.read_at.nil?
                  }

                when "pass_shared"
                  @notifications << {
                    "id": notification.id,
                    "pass_id": notification.resource.offer.id,
                    "event_name": notification.resource.offer.event.name,
                    "friend_name": User.get_full_name(notification.resource.user),
                    "business_name": User.get_full_name(notification.resource.offer.user),
                    "friend_id": notification.resource.user.id,
                    "actor_image": notification.actor.avatar,
                    "notifiable_id": notification.notifiable_id,
                    "notifiable_type": notification.notifiable_type,
                    "action": notification.action,
                    "action_type": notification.action_type,
                    "created_at": notification.created_at,
                    "is_read": !notification.read_at.nil?,
                    "event_start_date": notification.resource.offer.event.start_date
                    }

                  when "special_offer_shared"
                    @notifications << {
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

                    when "competition_shared"
                      @notifications << {
                        "id": notification.id,
                        "competition_id": notification.resource.offer.id,
                        "competition_name": notification.resource.offer.title,
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

                      when "event_shared"
                        @notifications << {
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
                          "business_name": User.get_full_name(notification.resource.child_event.user),
                          "event_name": notification.resource.child_event.name,
                          "event_id": notification.resource.child_event.id,
                          "event_location": eval(notification.resource.child_event.location)["city"] + ", " + eval(notification.resource.child_event.location)["country"],
                          "event_start_date": notification.resource.child_event.start_date,
                          "friend_name": User.get_full_name(notification.resource.user)
                        }

                      else
                        "do nothing"
                      end #switch

                    end #end

            render json: {
                code: 200,
                success: true,
                message: '',
                data: {
                  notifications: @notifications,
                  "unread_count": request_user.notifications.unread.size
                }
              }
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
                "friend_name": User.get_full_name(notification.actor),
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

       api :POST, '/api/v1/send-location', 'Send location to list of users'
        #param :askee_ids, :number, :desc => "askee_ids(1,2,3)", :required => true
        #param :lat, :number, :desc => "latitude", :required => true
        #param :lng, :number, :desc => "longitude", :required => true

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
                "friend_name": User.get_full_name(notification.actor),
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

       api :GET, '/api/v1/notifications/mark-as-read', 'Make notification mark as read'

     def mark_as_read
        if request_user.notifications.unread.update_all(read_at: Time.zone.now)
          render json: {
            code: 200,
            success: true,
            message: "Notification read successfully.",
            data: nil
          }
        else
          render json: {
            code: 400,
            success: false,
            message: "Notification read failed.",
            data: nil
          }
        end
    end

      api :GET, '/api/v1/send_events_reminder', 'Send event reminders to interested participants before ony day'

    def send_events_reminder
      interested_in_events = request_user.interested_in_events
      #send reminder about interested in events
       @reminder_sent = false;
       @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
        )
       interested_in_events.each do |event|
        start_date = event.start_date
        start_date_yesterday = (start_date - 1.day).to_date
        now = Time.now.to_date
        if now  ==  start_date_yesterday
         check = request_user.reminders.where(event_id: event.id).where(level: 'interested')
         if check.blank?
          if @reminder = request_user.reminders.create!(event_id: event.id, level: 'interested')
            if notification = Notification.create!(recipient: request_user, actor: request_user, action: "You are interested in event '#{event.name}' which is happening tomorrow. ", notifiable: event, resource: event, url: "/admin/events/#{event.id}", notification_type: 'mobile', action_type: "#{event.price_type}_event_reminder")

               @current_push_token = @pubnub.add_channels_to_push(
                 push_token: request_user.device_token,
                 type: 'gcm',
                 add: request_user.device_token
                 ).value

                 case event.price_type
                  when "free"
                    data = {
                      "id": notification.id,
                      "event_name": notification.resource.name,
                      "event_id": notification.resource.id,
                      "event_location": notification.resource.location,
                      "event_start_date": notification.resource.start_date,
                      "event_start_time": notification.resource.start_time,
                      "event_end_time": notification.resource.end_time,
                      "event_type": notification.resource.event_type,
                      "actor_image": notification.actor.avatar,
                      "notifiable_id": notification.notifiable_id,
                      "notifiable_type": notification.notifiable_type,
                      "action": notification.action,
                      "action_type": notification.action_type,
                      "created_at": notification.created_at,
                      "is_read": !notification.read_at.nil?
                    }
                  when  "buy"
                     data ={
                      "id": notification.id,
                      "event_name": notification.resource.name,
                      "event_id": notification.resource.id,
                      "event_location": notification.resource.location,
                      "event_start_date": notification.resource.start_date,
                      "event_start_time": notification.resource.start_time,
                      "event_end_time": notification.resource.end_time,
                      "event_type": notification.resource.event_type,
                      "actor_image": notification.actor.avatar,
                      "notifiable_id": notification.notifiable_id,
                      "notifiable_type": notification.notifiable_type,
                      "action": notification.action,
                      "action_type": notification.action_type,
                      "created_at": notification.created_at,
                      "is_read": !notification.read_at.nil?
                     }
                  when  "pay_at_door"
                    data = {
                      "id": notification.id,
                      "event_name": notification.resource.name,
                      "event_id": notification.resource.id,
                      "event_location": notification.resource.location,
                      "event_start_date": notification.resource.start_date,
                      "event_start_time": notification.resource.start_time,
                      "event_end_time": notification.resource.end_time,
                      "event_type": notification.resource.event_type,
                      "actor_image": notification.actor.avatar,
                      "notifiable_id": notification.notifiable_id,
                      "notifiable_type": notification.notifiable_type,
                      "action": notification.action,
                      "action_type": notification.action_type,
                      "created_at": notification.created_at,
                      "is_read": !notification.read_at.nil?
                    }
                  else
                    "do nothing"
                  end

                payload = {
                "pn_gcm":{
                  "notification":{
                    "title": "Reminder about '#{event.name}'",
                    "body": notification.action
                  },
                  data: data
                }
              }

                @pubnub.publish(
                  channel: [request_user.device_token],
                  message: payload
                   ) do |envelope|
                     puts envelope.status
                 end
                 @reminder_sent = true;
               end ##notification create
           end #reminder
         end #cheak
        end #time equal
      end # each

      request_user.events_to_attend.each do |event|
        end_date = event.end_date
        end_date_yesterday = (end_date - 1.day).to_date
        now = Time.now.to_date
        if now  ==  end_date_yesterday
         check = request_user.reminders.where(event_id: event.id).where(level: 'going')
         if check.blank?
          if @reminder = request_user.reminders.create!(event_id: event.id, level: 'going')
            if @notification = Notification.create!(recipient: request_user, actor: request_user, action: "You are attening an event '#{event.name}' which is happening tomorrow. ", notifiable: event, resource: event, url: "/admin/events/#{event.id}", notification_type: 'mobile', action_type: "event_reminder")

               @current_push_token = @pubnub.add_channels_to_push(
                 push_token: request_user.device_token,
                 type: 'gcm',
                 add: request_user.device_token
                 ).value

                payload = {
                "pn_gcm":{
                  "notification":{
                    "title": "Reminder about '#{event.name}'",
                    "body": @notification.action
                  },
                  data: {
                    "id": @notification.id,
                    "actor_id": @notification.actor_id,
                    "actor_image": @notification.actor.avatar,
                    "notifiable_id": @notification.notifiable_id,
                    "notifiable_type": @notification.notifiable_type,
                    "action_type": @notification.action_type,
                    "location": location,
                    "action": @notification.action,
                    "created_at": @notification.created_at,
                    "body": ''
                  }
                }
              }

                @pubnub.publish(
                  channel: [request_user.device_token],
                  message: payload
                   ) do |envelope|
                     puts envelope.status
                 end
                 @reminder_sent = true;
               end ##notification create
           end #reminder
         end #cheak
        end #time equal
      end # each

        if  @reminder_sent
          render json: {
            code: 200,
            success: true,
            message: 'Reminder sent successfully.',
            data: nil
          }
        else
          render json: {
            code: 400,
            success: false,
            message: 'Reminder was not sent.',
            token: request_user.device_token,
            data: nil
          }
        end
    end

  api :POST, '/api/v1/notifications/delete-notification', 'Delete a notification'
  # param :notification_id, String, :desc => "Notification ID", :required => true



    def delete_notification
     if !params[:notification_id].blank?
       notification = Notification.find(params[:notification_id])
        if notification.destroy
          render json: {
            code: 200,
            success: true,
            message: "Notification deleted successfully.",
            data: nil
          }
        else
          render json: {
            code: 400,
            success: false,
            message: "Notification deletion failed.",
            data: nil
          }
        end
        else
          render json: {
            code: 400,
            success: false,
            message: 'notification_id is required field.',
            data: nil
          }
        end
   end


   def read_notification
      if !params[:notification_id].blank?
        notification = Notification.find(params[:notification_id])
        if notification.update!(read_at: Time.now)
          render json: {
            code: 200,
            success: true,
            message: 'Notification read successfully.',
            data: nil
          }
        else
          render json: {
            code: 400,
            success: false,
            message: 'Notification read was unsuccessful.',
            data: nil
          }
        end
      else
        render json: {
          code: 400,
          success: false,
          message: 'notification_id is required.',
          data: nil
        }
      end
   end



end
