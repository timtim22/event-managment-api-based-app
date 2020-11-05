class Dashboard::Api::V1::CompetitionsController < Dashboard::Api::V1::ApiMasterController
    before_action :authorize_request, except:  ['index']
    require 'json'
    require 'pubnub'
    require 'action_view'
    require 'action_view/helpers'
    include ActionView::Helpers::DateHelper
 
    def get_past_competitions
    @competitions = []
    Competition.page(params[:page]).per(20).expired.order(created_at: 'DESC').each do |competition|
      location = {
        "name" => competition.location,
        "geometry" => {
          "lat" => competition.lat,
          'lng' => competition.lng
        }
     }

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
       location: location,
       draw_date: competition.end_date.strftime("%a %d %b %y%:z "),
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
    render json: {
      code: 200,
      success: true,
      message:'',
      data: {
        competitions: @competitions
      }
    }
  end

  def show
   comp = Competition.find(params[:id])

   location = {
   "name" => comp.location,
   "geometry" => {
     "lat" => comp.lat,
     'lng' => comp.lng
       }
     }

     @competition = {
       'id' => comp.id,
       'title' => comp.title,
       'description' => comp.description,
       'image' => comp.image,
       'start_date' => comp.start_date,
       'end_date' => comp.end_date,
       'start_time' => comp.start_time,
       'end_time' => comp.end_time,
       'location' => comp.location,
       'validity' => comp.validity,
       'validity_time' => comp.validity_time,
       'validity_time' => comp.validity_time,
       'price' => comp.price,
       'terms_conditions' => comp.terms_conditions,
       'winner' => comp.competition_winners.size

      }
  
     render json: {
       code: 200,
       success: true,
       message: '',
       data: {
         competition: @competition
       }
     }

  end

  
  def create
    @competition = Competition.new
    @competition.title = params[:title]
    @competition.description = params[:description]
    @competition.start_date = params[:start_date]
    @competition.end_date = params[:end_date]
    @competition.start_time = params[:start_time]
    @competition.end_time = params[:end_time]
    @competition.validity = params[:validity]
    @competition.validity_time = params[:validity_time]
    @competition.image = params[:image]
    @competition.price = params[:price]
    @competition.terms_conditions = params[:terms_conditions]
    @competition.location = params[:location]

    if @competition.save
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
      # create_activity("created competition", @competition, "Competition", admin_competition_path(@competition),@competition.title, 'post')
      if !request_user.followers.blank?
        request_user.followers.each do |follower|
       if follower.competitions_notifications_setting.is_on == true
          if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " created a new competition '#{@competition.title}'.", notifiable: @competition, url: "/admin/competitions/#{@competition.id}", notification_type: 'mobile', action_type: 'create_competition') 
      
            @current_push_token = @pubnub.add_channels_to_push(
             push_token: follower.profile.device_token,
             type: 'gcm',
             add: follower.profile.device_token
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
         channel: follower.profile.device_token,
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
            message: 'Competition created successfully.',
            data: nil
          }
    else
    render json: {
            code: 400,
            success: false,
            message: @competition.errors.full_messages,
            data: nil

          }    
    end
  end

  def edit
    @competition = Competition.find(params[:id])
  end

  def update
    if !params[:id].blank?
    @competition = Competition.find(params[:id])
    @competition.title = params[:title]
    @competition.description = params[:description]
    @competition.start_date = params[:start_date]
    @competition.end_date = params[:end_date]
    @competition.start_time = params[:start_time]
    @competition.end_time = params[:end_time]
    @competition.validity = params[:validity]
    @competition.validity_time = params[:validity_time]
    @competition.image = params[:image]
    @competition.price = params[:price]
    @competition.location = params[:location]

    if @competition.save
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
      # create_activity("created competition", @competition, "Competition", admin_competition_path(@competition),@competition.title, 'post')
      if !request_user.followers.blank?
        request_user.followers.each do |follower|
       if follower.competitions_notifications_setting.is_on == true
          if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " Updated new competition '#{@competition.title}'.", notifiable: @competition, url: "/admin/competitions/#{@competition.id}", notification_type: 'mobile', action_type: 'create_competition') 
          
            @current_push_token = @pubnub.add_channels_to_push(
             push_token: follower.profile.device_token,
             type: 'gcm',
             add: follower.profile.device_token
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
               channel: follower.profile.device_token,
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
                message: 'Competition updated successfully.',
                data: nil
              }
    else
        render json: {
                code: 400,
                success: false,
                message: @competition.errors.full_messages,
                data: nil

              }    
    end
    
  else
    render json: {
      code: 400,
      success: false,
      message: "id is required.",
      data: nil

    }
  end
end


  def destroy
    @competition = Competition.find(params[:id])
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
   end

  private


  def competition_params
		params.permit(:title,:user_id,:description,:start_date,:end_date,:price,:start_time, :end_time,:image,:validity,:validity_time,:lat,:lng,:location,:host)
  end


end
