class Dashboard::Api::V1::Competitions::CompetitionsController < Dashboard::Api::V1::ApiMasterController
    before_action :authorize_request, except:  ['index']

    require 'json'
    require 'pubnub'
    require 'action_view'
    require 'action_view/helpers'
    include ActionView::Helpers::DateHelper

    resource_description do
      api_versions "dashboard"
    end

  api :GET, '/dashboard/api/v1/get-past-competitions', 'Get past/expired competitions'

    def get_past_competitions
    @competitions = []
    Competition.page(params[:page]).per(20).expired.order(created_at: 'DESC').each do |competition|

     winners = []
     competition.competition_winners.each do |winner|
       winners << {
         "id" => winner.user.id,
         "name" => get_full_name(winner.user),
         "avatar" => winner.user.avatar
       }
     end

      @competitions << {
       id: competition.id,
       title: competition.title,
       image: competition.image.url,
       draw_time: competition.draw_time,
       views: 0,
       entries: competition.registrations.size,
       winners: winners

      }
    end
    render json: {
      code: 200,
      success: true,
      message: "",
      data:  {
        competitions: @competitions
      }
    }
  end

  def index
    @competitions = request_user.competitions.page(params[:page]).per(20).order(created_at: "DESC")
    @comp = []
    @competitions.each do |comp|

      case
      when comp.draw_time > Time.now
        entries =  comp.registrations.size.to_s + " Entries"
      when comp.draw_time < Time.now
        entries =  "Draw Over"
      end

      @comp << {
        id: comp.id,
        title: comp.title,
        description: comp.description,
        image: comp.image,
        terms_conditions: comp.terms_conditions,
        over_18: comp.over_18,
        number_of_winner: comp.number_of_winner,
        status: comp.status,
        draw_date: comp.draw_time.strftime("%Y-%m-%d"),
        draw_time: comp.draw_time.strftime("%H:%M"),
        entries: entries,
        registrations: comp.registrations.size,
        get_demographics: get_competition_demographics(comp)


      }
    end
    render json: {
      code: 200,
      success: true,
      message:'',
      data: {
        competitions: @comp
      }
    }
  end

  # api :GET, '/dashboard/api/v1/competitions/:id', 'Shows a competition'
  # param :id, :number, desc: "id of the competition"
  def show
    if !params[:competition_id].blank?
      if Competition.where(id: params[:competition_id]).exists?
        comp = Competition.find(params[:competition_id])

          case
          when comp.draw_time > Time.now
            entries =  comp.registrations.size.to_s + " Entries"
          when comp.draw_time < Time.now
            entries =  "Draw Over"
          end
         @competition = {
           'id' => comp.id,
           'title' => comp.title,
           'description' => comp.description,
           'image' => comp.image,
           'draw_date' => comp.draw_time.strftime("%Y-%m-%d"),
           'draw_time' => comp.draw_time.strftime("%H:%M"),
           'over_18' => comp.over_18,
           'terms_conditions' => comp.terms_conditions,
           'number_of_winner' => comp.number_of_winner,
           'status' => comp.status,
           'winner' => comp.competition_winners.size,
           'entries' => entries,
           'registrations' => comp.registrations.size

          }

         render json: {
           code: 200,
           success: true,
           message: '',
           data: {
             competition: @competition
           }
         }
      else
        render json: {
          code: 400,
          success: false,
          message: "competition doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "competition_id is required" ,
        data: nil
      }
    end

  end


def add_image
  if params[:competition_id].blank?
    @competition = request_user.competitions.new
    @competition.image = params[:image]
    @competition.draw_time = "00:00:00"
    @competition.status = "draft"
      if @competition.save
          render json: {
            code: 200,
            success: true,
            message: 'Competition created and image added successfully',
            data: {
              id: @competition.id,
              image: @competition.image 
            }
          }
      else
          render json: {
            code: 400,
            success: false,
            message: 'Competition creation failed',
            data: nil
          }
      end
  else
    if Competition.where(id: params[:competition_id]).exists?
      @competition = Competition.find(params[:competition_id])
      @competition.image = params[:image]
      @competition.save
          render json: {
            code: 200,
            success: true,
            message: 'Image updated successfully',
            data: {
              id: @competition.id,
              image: @competition.image 
            }
          }
    else
        render json: {
          code: 400,
          success: false,
          message: "competition doesnt exist" ,
          data: nil
        }
    end
  end
end

  def add_details
    if !params[:competition_id].blank?
      if Competition.where(id: params[:competition_id]).exists?
        @competition = Competition.find(params[:competition_id])
        @competition.title = params[:title]
        @competition.description = params[:description]
        @competition.over_18 = params[:over_18]
        @competition.number_of_winner = params[:number_of_winner]

        @competition.save
          render json: {
            code: 200,
            success: true,
            message: 'Details added successfully',
            data: {
              id: @competition.id,
              title: @competition.title, 
              description: @competition.description, 
              over_18: @competition.over_18, 
              limited: @competition.number_of_winner
            }
          }
      else
          render json: {
            code: 400,
            success: false,
            message: "Competition doesnt exist" ,
            data: nil
          }
      end
    else
          render json: {
            code: 400,
            success: false,
            message: "competition_id is required" ,
            data: nil
          }
    end
  end

  def draw_time
    if !params[:competition_id].blank?
      if Competition.where(id: params[:competition_id]).exists?
        @competition = Competition.find(params[:competition_id])
        @competition.draw_time = get_date_time(params[:draw_date].to_date, params[:draw_time])
        @competition.save
          render json: {
            code: 200,
            success: true,
            message: 'Draw time added successfully',
            data: {
              id: @competition.id,
              draw_time: @competition.draw_time
            }
          }

      else
        render json: {
          code: 400,
          success: false,
          message: "Competition doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "competition_id is required" ,
        data: nil
      }
    end
  end

  def terms_conditions
    if !params[:competition_id].blank?
      if Competition.where(id: params[:competition_id]).exists?
        @competition = Competition.find(params[:competition_id])
        @competition.terms_conditions = params[:terms_conditions]
        @competition.save
          render json: {
            code: 200,
            success: true,
            message: 'Terms and Condition added successfully',
            data: {
              id: @competition.id,

              draw_time: @competition.terms_conditions
            }
          }
      else
        render json: {
          code: 400,
          success: false,
          message: "Competition doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "competition_id is required" ,
        data: nil
      }
    end
  end

  def publish_competition
    if !params[:competition_id].blank?
      if Competition.where(id: params[:competition_id]).exists?
        @competition = Competition.find(params[:competition_id])
        @competition.status = "active"
        @competition.save
          if !request_user.followers.blank?
            @pubnub = Pubnub.new(
              publish_key: ENV['PUBLISH_KEY'],
              subscribe_key: ENV['SUBSCRIBE_KEY'],
              uuid: @username
              )
            request_user.followers.each do |follower|
           if follower.competitions_notifications_setting.is_on == true
              if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " created a new competition '#{@competition.title}'.", notifiable: @competition, resource: @competition, url: "/admin/competitions/#{@competition.id}", notification_type: 'mobile', action_type: 'create_competition')

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
              end # notification end
          end #competition setting
          end #each
          end # not blank
          render json: {
            code: 200,
            success: true,
            message: 'Competition successfully published',
            data: {
              id: @competition.id,
              image: @competition.image,
              title: @competition.title,
              description: @competition.description,
              over_18: @competition.over_18,
              number_of_winner: @competition.number_of_winner,
              draw_time: @competition.draw_time,
              terms_conditions: @competition.terms_conditions
            }
          }
      else
        render json: {
          code: 400,
          success: false,
          message: "Competition doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "competition_id is required" ,
        data: nil
      }
    end
  end


  # def create
  #   @competition = request_user.competitions.new
  #   @competition.title = params[:title]
  #   @competition.description = params[:description]
  #   @competition.start_date = get_date_time(params[:start_date].to_date, params[:start_time])
  #   @competition.end_date = get_date_time(params[:end_date].to_date, params[:end_time])
  #   @competition.image = params[:image]
  #   @competition.terms_conditions = params[:terms_conditions]
  #   @competition.number_of_winner = params[:number_of_winner]
  #   @competition.over_18 = params[:over_18]
  #   @competition.competition_forwarding = params[:competition_forwarding]

  #   if @competition.save
  #     @pubnub = Pubnub.new(
  #       publish_key: ENV['PUBLISH_KEY'],
  #       subscribe_key: ENV['SUBSCRIBE_KEY']
  #      )
  #     # create_activity("created competition", @competition, "Competition", admin_competition_path(@competition),@competition.title, 'post')
  #     if !request_user.followers.blank?
  #       request_user.followers.each do |follower|
  #      if follower.competitions_notifications_setting.is_on == true
  #         if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " created a new competition '#{@competition.title}'.", notifiable: @competition, resource: @competition, url: "/admin/competitions/#{@competition.id}", notification_type: 'mobile', action_type: 'create_competition')

  #           @current_push_token = @pubnub.add_channels_to_push(
  #            push_token: follower.device_token,
  #            type: 'gcm',
  #            add: follower.device_token
  #            ).value

  #            payload = {
  #             "pn_gcm":{
  #              "notification":{
  #                "title": get_full_name(request_user),
  #                "body": @notification.action
  #              },
  #              data: {
  #               "id": @notification.id,
  #               "actor_id": @notification.actor_id,
  #               "actor_image": @notification.actor.avatar,
  #               "notifiable_id": @notification.notifiable_id,
  #               "notifiable_type": @notification.notifiable_type,
  #               "action": @notification.action,
  #               "action_type": @notification.action_type,
  #               "created_at": @notification.created_at,
  #               "body": ''
  #              }
  #             }
  #            }

  #      @pubnub.publish(
  #        channel: follower.device_token,
  #        message: payload
  #        ) do |envelope|
  #            puts envelope.status
  #          end
  #         end # notification end
  #     end #competition setting
  #     end #each
  #     end # not blank
  #   render json: {
  #           code: 200,
  #           success: true,
  #           message: 'Competition created successfully.',
  #           data: @competition
  #         }
  #   else
  #   render json: {
  #           code: 400,
  #           success: false,
  #           message: @competition.errors.full_messages,
  #           data: nil

  #         }
  #   end
  # end


#   def update
#     if !params[:id].blank?
#     @competition = Competition.find(params[:id])
#     @competition.title = params[:title]
#     @competition.description = params[:description]
#     @competition.start_date = get_date_time(params[:start_date].to_date, params[:start_time])
#     @competition.end_date = get_date_time(params[:end_date].to_date, params[:end_time])
#     @competition.image = params[:image]
#     @competition.terms_conditions = params[:terms_conditions]
#     @competition.number_of_winner = params[:number_of_winner]
#     @competition.competition_forwarding = params[:competition_forwarding]

#     if @competition.save
#       @pubnub = Pubnub.new(
#         publish_key: ENV['PUBLISH_KEY'],
#         subscribe_key: ENV['SUBSCRIBE_KEY']
#        )
#       # create_activity("created competition", @competition, "Competition", admin_competition_path(@competition),@competition.title, 'post')
#       if !request_user.followers.blank?
#         request_user.followers.each do |follower|
#        if follower.competitions_notifications_setting.is_on == true
#           if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " Updated new competition '#{@competition.title}'.", notifiable: @competition, resource: @competition, url: "/admin/competitions/#{@competition.id}", notification_type: 'mobile', action_type: 'create_competition')

#             @current_push_token = @pubnub.add_channels_to_push(
#              push_token: follower.device_token,
#              type: 'gcm',
#              add: follower.device_token
#              ).value

#              payload = {
#               "pn_gcm":{
#                "notification":{
#                  "title": get_full_name(request_user),
#                  "body": @notification.action
#                },
#                data: {
#                 "id": @notification.id,
#                 "actor_id": @notification.actor_id,
#                 "actor_image": @notification.actor.avatar,
#                 "notifiable_id": @notification.notifiable_id,
#                 "notifiable_type": @notification.notifiable_type,
#                 "action": @notification.action,
#                 "action_type": @notification.action_type,
#                 "created_at": @notification.created_at,
#                 "body": ''
#                }
#               }
#              }

#              @pubnub.publish(
#                channel: follower.device_token,
#                message: payload
#                ) do |envelope|
#                    puts envelope.status
#               end
#           end # notification end
#         end #competition setting
#       end #each
#     end # not blank
#         render json: {
#                 code: 200,
#                 success: true,
#                 message: 'Competition updated successfully.',
#                 data: @competition
#               }
#     else
#         render json: {
#                 code: 400,
#                 success: false,
#                 message: @competition.errors.full_messages,
#                 data: nil

#               }
#     end

#   else
#     render json: {
#       code: 400,
#       success: false,
#       message: "id is required.",
#       data: nil

#     }
#   end
# end

  # api :DELETE, 'dashboard/api/v1/competitions', 'To Delete a competition'
  # param :id, :number, :desc => "ID of the competition", :required => true

  def destroy
    if !params[:competition_id].blank?
      if Competition.where(id: params[:competition_id]).exists?
        @competition = Competition.find(params[:competition_id])
        if @competition.destroy
           render json: {
          code: 200,
          success: true,
          message: 'Competition successfully deleted.',
          data: nil
          }
        else
          render json:  {
            code: 400,
            success: false,
            message: 'Competition deletion failed.',
            data: nil
          }
        end
      else
        render json: {
          code: 400,
          success: false,
          message: "Competition doesnt exist" ,
          data: nil
        }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "competition_id is required" ,
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

  def competition_params
		params.permit(:title,:user_id,:description, :terms_conditions, :start_date,:end_date,:price,:start_time, :end_time,:image,:validity,:validity_time,:lat,:lng,:location,:host)
  end


end
