class Dashboard::Api::V1::CompetitionsController < Dashboard::Api::V1::ApiMasterController
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
       location: competition.location,
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

  api :POST, 'dashboard/api/v1/competitions', 'Get competitions by list'
  #param :location, String, :desc => "Location of the event", :required => true

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

  api :GET, '/dashboard/api/v1/competitions/:id', 'Shows a competition'
  param :id, :number, desc: "id of the competition"
  def show
   comp = Competition.find(params[:id])

     @competition = {
       'id' => comp.id,
       'title' => comp.title,
       'description' => comp.description,
       'image' => comp.image,
       'start_date' => comp.start_date,
       'location' => comp.location,
       'end_date' => comp.end_date,
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

  api :POST, '/dashboard/api/v1/competitions', 'To create competition'
  # param :title, String, :desc => "Title of the competition", :required => true
  # param :description, String, :desc => "Description of the competition", :required => true
  # param :start_date, String, :desc => "Start Date of the competition", :required => true
  # param :end_date, String, :desc => "End Date of the competition", :required => true
  # param :start_time, String, :desc => "Start time of the competition", :required => true
  # param :end_time, String, :desc => "End time of the competition", :required => true
  # param :validity, String, :desc => "Validity", :required => true
  # param :validity_time, String, :desc => "Validity Time", :required => true
  # param :image, String, :desc => "Image of the competition", :required => true
  # param :price, :decimal, :desc => "Price of the competition", :required => true
  # param :terms_conditions, String, :desc => "Terms and Condition of the competition", :required => true
 # param :location, String, :desc => "Location of the competition", :required => true


  def create
    @competition = request_user.competitions.new
    @competition.title = params[:title]
    @competition.description = params[:description]
    @competition.start_date = get_date_time(params[:start_date].to_date, params[:start_time])
    @competition.end_date = get_date_time(params[:end_date].to_date, params[:end_time])
    @competition.image = params[:image]
    @competition.terms_conditions = params[:terms_conditions]
    @competition.number_of_winner = params[:number_of_winner]
    @competition.over_18 = params[:over_18]
    @competition.competition_forwarding = params[:competition_forwarding]

    if @competition.save
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
      # create_activity("created competition", @competition, "Competition", admin_competition_path(@competition),@competition.title, 'post')
      if !request_user.followers.blank?
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
            message: 'Competition created successfully.',
            data: @competition
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

  api :PUT, '/dashboard/api/v1/competitions', 'To update competition'
  # param :id, String, :desc => "ID of the competition", :required => true
  # param :title, String, :desc => "Title of the competition", :required => true
  # param :description, String, :desc => "Description of the competition", :required => true
  # param :start_date, String, :desc => "Start Date of the competition", :required => true
  # param :end_date, String, :desc => "End Date of the competition", :required => true
  # param :start_time, String, :desc => "Start time of the competition", :required => true
  # param :end_time, String, :desc => "End time of the competition", :required => true
  # param :validity, String, :desc => "Validity", :required => true
  # param :validity_time, String, :desc => "Validity Time", :required => true
  # param :image, String, :desc => "Image of the competition", :required => true
  # param :price, :decimal, :desc => "Price of the competition", :required => true
  # param :terms_conditions, String, :desc => "Terms and Condition of the competition", :required => true
  #param :location, String, :desc => "Location of the competition", :required => true

  def update
    if !params[:id].blank?
    @competition = Competition.find(params[:id])
    @competition.title = params[:title]
    @competition.description = params[:description]
    @competition.start_date = get_date_time(params[:start_date].to_date, params[:start_time])
    @competition.end_date = get_date_time(params[:end_date].to_date, params[:end_time])
    @competition.image = params[:image]
    @competition.terms_conditions = params[:terms_conditions]
    @competition.number_of_winner = params[:number_of_winner]
    @competition.competition_forwarding = params[:competition_forwarding]

    if @competition.save
      @pubnub = Pubnub.new(
        publish_key: ENV['PUBLISH_KEY'],
        subscribe_key: ENV['SUBSCRIBE_KEY']
       )
      # create_activity("created competition", @competition, "Competition", admin_competition_path(@competition),@competition.title, 'post')
      if !request_user.followers.blank?
        request_user.followers.each do |follower|
       if follower.competitions_notifications_setting.is_on == true
          if @notification = Notification.create!(recipient: follower, actor: request_user, action: get_full_name(request_user) + " Updated new competition '#{@competition.title}'.", notifiable: @competition, resource: @competition, url: "/admin/competitions/#{@competition.id}", notification_type: 'mobile', action_type: 'create_competition')

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
                message: 'Competition updated successfully.',
                data: @competition
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

  api :DELETE, 'dashboard/api/v1/competitions', 'To Delete a competition'
  param :id, :number, :desc => "ID of the competition", :required => true

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


 def get_date_time(date, time)
    d = date.strftime("%Y-%b-%d")
    t = time.to_time.strftime("%H:%M:%S")
    datetime = d + " " + t
 end

  def competition_params
		params.permit(:title,:user_id,:description, :terms_conditions, :start_date,:end_date,:price,:start_time, :end_time,:image,:validity,:validity_time,:lat,:lng,:location,:host)
  end


end
