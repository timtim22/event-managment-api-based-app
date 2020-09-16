class Api::V1::CompetitionsController < Api::V1::ApiMasterController
    before_action :authorize_request, except:  ['index']
    require 'json'
    require 'pubnub'
    require 'action_view'
    require 'action_view/helpers'
    include ActionView::Helpers::DateHelper
 
    def index
    @competitions = []
    if request_user
     
    Competition.not_expired.order(created_at: 'DESC').each do |competition|
      if !is_removed_competition?(request_user, competition) && showability?(request_user, competition) 
        @competitions << {
        id: competition.id,
        title: competition.title,
        description: competition.description,
        location: competition.location,
        start_date: competition.start_date,
        end_date: competition.end_date,
        start_time: competition.start_time,
        end_time: competition.end_time,
        price: competition.price,
        lat: competition.lat,
        lng: competition.lng,
        image: competition.image.url,
        is_entered: is_entered_competition?(competition.id),
        participants_stats: get_participants_stats(competition),
        creator_name: competition.user.business_profile.profile_name,
        creator_image: competition.user.avatar,
        creator_id: competition.user.id,
        total_entries_count: get_entry_count(request_user, competition),
        issued_by: get_full_name(competition.user),
        is_followed: is_followed(competition.user),
        validity: competition.validity.strftime(get_time_format),
        terms_and_conditions: competition.terms_conditions
        }
     end
    end #each
  else
    Competition.not_expired.order(created_at: 'DESC').each do |competition|
      @competitions << {
      id: competition.id,
      title: competition.title,
      description: competition.description,
      location: competition.location,
      start_date: competition.start_date,
      end_date: competition.end_date,
      start_time: competition.start_time,
      end_time: competition.end_time,
      price: competition.price,
      lat: competition.lat,
      lng: competition.lng,
      image: competition.image.url,
      is_entered: is_entered_competition?(competition.id),
      participants_stats: get_participants_stats(competition),
      creator_name: competition.user.business_profile.profile_name,
      creator_image: competition.user.avatar,
      creator_id: competition.user.id,
      total_entries_count: 0,
      issued_by: get_full_name(competition.user),
      is_followed: is_followed(competition.user),
      validity: competition.validity.strftime(get_time_format),
      terms_and_conditions: competition.terms_conditions
      }
    end #each
  end #if
    render json: {
      code: 200,
      success: true,
      message: "",
      data:  {
        competitions: @competitions
      }
    }
  end



  def register
    if !params[:competition_id].blank?
      @competition = Competition.find(params[:competition_id])
      if @competition.user != request_user
      check = @competition.registrations.where(user_id: request_user.id)
      if !check.blank?
         last_entry = check.last
         entry_time = last_entry.created_at
         after_24_hours = entry_time + 24.hours
         if after_24_hours < Time.now 
           @registration = @competition.registrations.create!(user: request_user)
           render json: {
            code: 200,
            success: true,
            message: "You entered the competition successfully.",
            data: nil
          } 
         else
          render json: {
            code: 400,
            success: false,
            message: 'You have already entered this competition. You can re-enter after 24 hours.',
            data: nil
          }
         end # if 24 hours passed

      else
        @registration = @competition.registrations.create!(user: request_user)
        render json: {
         code: 200,
         success: true,
         message: "You entered the competition successfully.",
         data: nil
       } 
    end #if already enter
  else
    render json: {
      code: 400,
      success: false,
      message: "You can't enter your own competition",
      data: nil
    }
  end
    else
      render json: {
        code: 400,
        success: false,
        message: 'competition_id is required field.',
        data: nil
      }
    end

  end







 

 

  def get_winner_and_notify
    registrations = Registration.where(event_type: 'Competition')
    if !registrations.blank?
      success = false;
      registrations.each do |reg|
        competition = reg.event
          if competition.end_date.to_date == Time.now.to_date
              user_ids = []
              user_ids.push(reg.user_id)
              winner = User.find(user_ids.sample) # .sample will pick an id randomly
              participants = User.where(id: [user_ids])
              CompetitionWinner.create!(user_id: winner.id, competition_id: competition.id)
               participants.each do |participant|  
                 notification = Notification.where(recipient: participant).where(notifiable: competition).where(action_type: 'get_winner_and_notify').first
                if notification.blank?
                  if @notification = Notification.create(recipient: participant, actor: winner, action: get_full_name(winner) + " is the winner.", notifiable: competition, url: "", notification_type: 'mobile', action_type: 'get_winner_and_notify')
                    success = true 
                 
                    @pubnub = Pubnub.new(
                      publish_key: ENV['PUBLISH_KEY'],
                      subscribe_key: ENV['SUBSCRIBE_KEY']
                    )
                    end
        
                    @current_push_token = @pubnub.add_channels_to_push(
                       push_token: participant.profile.device_token,
                       type: 'gcm',
                       add: participant.profile.device_token
                       ).value
            
                     payload = { 
                      "pn_gcm":{
                       "notification":{
                         "title": competition.title,
                         "body": @notification.action
                       }
                      }
                     }
                     @pubnub.publish(
                      channel: participant.profile.device_token,
                      message: payload
                      ) do |envelope|
                          puts envelope.status
                     end
                  end #notification create
                end
          end #end date
      end #each
      if success
        render json: {
          code: 200,
          success: true,
          message: 'Notification sent.',
          data: nil
        }
      else
        render json: {
          code: 400,
          success: false,
          message: 'Notification was not sent.',
          data: nil
        }
      end
    else
      render json: {
        code: 200,
        success: true,
        message: 'No competition registration found.',
        data: nil
      }
    end #blank  
  end


#   def get_winner_and_notify
#     @competitions = Competition.all
#     if !@competitions.blank?
#      notified = false
#      success = false;
#      @competitions.each do |competition|
#       # Check end date
#       if competition.end_date.to_date == Time.now.to_date
#         # Get users registered for the contest with an end date today
#       if !competition.registrations.blank?
#         user_ids = competition.registrations.map {|reg| reg.user.id } 
#         winner = User.find(user_ids.sample) # .sample will pick an id randomly
#         participants = User.where(id: [user_ids])
#         CompetitionWinner.create!(user_id: winner.id, competition_id: competition.id)
#         participants.each do |participant|  
#            notification = Notification.where(recipient: participant).where(notifiable: competition).where(action_type: 'get_winner_and_notify').first
#            if notification.blank?
#           if @notification = Notification.create(recipient: participant, actor: winner, action: get_full_name(winner) + " is the winner.", notifiable: competition, url: "", notification_type: 'mobile', action_type: 'get_winner_and_notify')
#             success = true 
#             notified = true
#             @pubnub = Pubnub.new(
#               publish_key: ENV['PUBLISH_KEY'],
#               subscribe_key: ENV['SUBSCRIBE_KEY']
#             )
#             end

#             @current_push_token = @pubnub.add_channels_to_push(
#                push_token: participant.device_token,
#                type: 'gcm',
#                add: participant.device_token
#                ).value
    
#              payload = { 
#               "pn_gcm":{
#                "notification":{
#                  "title": competition.title,
#                  "body": @notification.action
#                }
#               }
#              }
#              @pubnub.publish(
#               channel: participant.device_token,
#               message: payload
#               ) do |envelope|
#                   puts envelope.status
#              end
#           end #notification create
#       end #if
#       end #if
#     end #each

#   if success
#     render json: {
#       code: 200,
#       success: true,
#       message: 'Notification sent.',
#       data: nil

#     }
#   else
#     render json: {
#       code: 400,
#       success: false,
#       message: 'Notification was not sent.',
#       data: nil

#     }
#   end
# else
#   render json: {
#     code: 400,
#     success: false,
#     message: "Notification is already sent.",
#     data:nil
#   }
# end

#   else
#     render json: {
#       code: 200,
#       success: true,
#       message: 'No competition found.',
#       data: nil
#     }
#   end

#   end

def create_view
  if !params[:competition_id].blank?
    competition = Competition.find(params[:competition_id])
    if view = competition.views.create!(user_id: request_user.id)
      render json: {
        code: 200,
        success: true,
        message: 'View successfully created.',
        data: nil
      }
    else
      render json: {
        code: 400,
        success: false,
        message: 'View creation failed.',
        data: nil
      }
    end
  else
     render json: {
       code: 400,
       success: false,
       message: 'competition_id is requied field.'
     }
    
  end
end
 

 
  private
  
  


   
    def showability?(user, competition)
     if is_entered_competition?(competition.id)
        reg = competition.registrations.where(user: user).first
        entry_time = reg.created_at
        after_24_hours = entry_time + 24.hours
        after_24_hours < Time.now             
     else
      true
     end
    end

end
