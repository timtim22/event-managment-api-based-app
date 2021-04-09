class Dashboard::Api::V1::Users::UsersController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request, except: ['create_user', 'business_type', 'add_image', 'add_details', 'add_login', 'add_social', 'add_phone', 'link_accounts', 'invite_admin', 'admin_requests', 'accept_admin_request', 'get_device_token', 'get_user' ]
  before_action :checkout_logout, except: ['create_user', 'business_type', 'add_image', 'add_details', 'add_login', 'add_social', 'add_phone', 'link_accounts', 'invite_admin', 'admin_requests', 'accept_admin_request', 'get_device_token', 'get_user']
  require "pubnub"
  require 'action_view'
  require 'action_view/helpers'
  require 'json'
  include ActionView::Helpers::DateHelper


     resource_description do
      api_versions "dashboard"
    end

  api :GET, 'dashboard/api/v1/show-all-users', 'Get all users'
  # GET /users
  # def index
  def show_all_users
    app = Assignment.where(role_id: 5).map {|assignment| assignment.user }
    business = Assignment.where(role_id: 2).map {|assignment| assignment.user }

    render json: {
      code: 200,
      success: true,
      data: {
        users: {
          "businesses" => business,
          "app_users" => app
        }
      }
    }
  end

  # GET /users/{username}
  def get_user
    if !params[:user_id].blank?
          @user = User.find(params[:user_id])

          app = Assignment.where(role_id: 5).map {|assignment| assignment.user }.select { |e| e.id == params[:user_id]} 
          business = Assignment.where(role_id: 2).map {|assignment| assignment.user }.select { |e| e.id == params[:user_id]}.select {|e| e.status == "active"}

          profile = {
              "user_id" => @user.id,
              "email" =>  @user.email,
              "avatar" => @user.avatar,
              "phone_number" =>  @user.phone_number,
              "password" => @user.password,
              "followers_count" => @user.followers.size,
              "location" => jsonify_location(@user.location),
              "is_subscribed" => @user.is_subscribed,
              "device_token" => @user.device_token,
              "about" => @user.about,
              "profile_name" => @user.business_profile.profile_name,
              "contact_name" => @user.business_profile.contact_name,
              "display_name" => @user.business_profile.display_name,
              "website" => @user.business_profile.website,
              "description" => @user.business_profile.description,
              "vat_number" => @user.business_profile.vat_number,
              "charity_number" => @user.business_profile.charity_number,
              "is_charity" => @user.business_profile.is_charity,
              "youtube" => @user.social_media.youtube,
              "instagram" => @user.social_media.instagram,
              "linkedin" => @user.social_media.linkedin,
              "facebook" => @user.social_media.facebook,
              "twitter" => @user.social_media.twitter,
              "snapchat" => @user.social_media.snapchat,
              "phone_details" => jsonify_phone_details(@user.phone_details),
              "link_accounts" => {
                "app_users" => app,
                "business" => business
              }
              }

          render json: {
           code: 200,
           success: true,
           message: '',
           data: {
             event: profile
              }
            }
    else
          render json: {
           code: 200,
           success: true,
           message: 'user_id is required',
           data: nil
         }

    end
    # render json: @user, status: :ok
  end

def business_type
  if !params[:user_id].blank?
    if User.where(id: params[:user_id]).exists?
      @user = User.find(params[:user_id])
      @business = @user.business_profile
      @business.is_charity = params[:is_charity]

        if @business.save
          render json: {
            code: 200,
            success: true,
            message: "Business type updated",
            data: {
              "id" => @user.id, 
              "is_charity" => @business.is_charity
            }
          }
        else
          render json: {
            code: 400,
            success: false,
            message: @business.errors.full_messages,
            data: nil
          }
        end
    else
          render json: {
            code: 400,
            success: false,
            message: "User doesnt exist" ,
            data: nil
          }
    end
  else
      @user = User.new
      @user.status = "draft"
      @user.save
      if @user.save
        @user.assignments.create!(role_id: 2)
        @business = BusinessProfile.new

        @business.user = @user
        @business.is_charity = params[:is_charity]

        if @business.save
          render json: {
            code: 200,
            success: true,
            message: "Business Type Added",
            data: {
              "id" => @user.id, 
              "is_charity" => @business.is_charity
            }
          }
        else
          render json: {
            code: 400,
            success: false,
            message: @business.errors.full_messages,
            data: nil
          }
        end
      else
          render json: {
            code: 400,
            success: false,
            message: @user.errors.full_messages,
            data: nil
          }
      end
  end
end


def add_image
  if !params[:user_id].blank?
    if User.where(id: params[:user_id]).exists?
      @user = User.find(params[:user_id])
      @user.avatar = params[:avatar]

      if @user.save
          render json: {
            code: 200,
            success: true,
            message: "Image added",
            data: {
              "id" => @user.id,
              "image" => @user.avatar 
          }
        }
      else
          render json: {
            code: 400,
            success: false,
            message: @user.errors.full_messages,
            data: nil
          }
      end
    else
          render json: {
            code: 400,
            success: false,
            message: "User doesnt exist",
            data: nil
          }
    end
  else
          render json: {
            code: 400,
            success: false,
            message: "user_id is required",
            data: nil
          }
  end
end

def add_details
  if !params[:user_id].blank?
    if User.where(id: params[:user_id]).exists?
      @user = User.find(params[:user_id])
      @user.location = params[:location]
      if @user.save
        if @user.business_profile.present?
          @business = @user.business_profile
          @business.profile_name = params[:profile_name]
          @business.display_name = params[:display_name]
          @business.contact_name = params[:contact_name]
          @business.vat_number = params[:vat_number]
          @business.description = params[:description]
          if @business.is_charity == true
            @business.charity_number = params[:charity_number] 
          else
            @business.charity_number = "" 
          end
        else
          @business = BusinessProfile.new
          @business.user = @user
          @business.profile_name = params[:profile_name]
          @business.display_name = params[:display_name]
          @business.contact_name = params[:contact_name]
          @business.vat_number = params[:vat_number]
          if @business.is_charity == true
            @business.charity_number = params[:charity_number] 
          else
            @business.charity_number = "" 
          end
        end

        if @business.save
          render json: {
            code: 200,
            success: true,
            message: "Details added",
            data: {
              "id" => @user.id,
              "profile_name" => @business.profile_name, 
              "display_name" => @business.display_name, 
              "contact_name" => @business.contact_name, 
              "vat_number" => @business.vat_number, 
              "charity_number" => @business.charity_number, 
              "location" => jsonify_location(@user.location),
              "description" => @business.description 
          }
        }
        else
          render json: {
            code: 400,
            success: false,
            message: @business.errors.full_messages,
            data: nil
          }
        end
      else
          render json: {
            code: 400,
            success: false,
            message: @user.errors.full_messages,
            data: nil
          }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "User doesnt exist",
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "user_id is required",
      data: nil
    }
  end
end

def add_login
  if !params[:user_id].blank?
    if User.where(id: params[:user_id]).exists?
      @user = User.find(params[:user_id])
      if !params[:email].blank? && !params[:password].blank?
        if !User.where(email: params[:email]).where(status: "active").exists?
          @user.email = params[:email]
          @user.password = params[:password]

          if @user.save
              render json: {
                code: 200,
                success: true,
                message: "Login details added",
                data: {
                  "id" => @user.id,
                  "email" => @user.email
              }
            }
          else
              render json: {
                code: 400,
                success: false,
                message: @user.errors.full_messages,
                data: nil
              }
          end
        else
            render json: {
              code: 400,
              success: false,
              message: "User already exist with the '#{params[:email]}' email" ,
              data: nil
            }
      end
      else
          render json: {
            code: 400,
            success: false,
            message: "email and password are required",
            data: nil
          }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "User doesnt exist",
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "user_id is required",
      data: nil
    }
  end
end

def add_social
  if !params[:user_id].blank?
    if User.where(id: params[:user_id]).exists?
      @user = User.find(params[:user_id])
      @business = @user.business_profile
      @business.website = params[:website]
      if @business.save
        if @user.social_media.present?
          @social = @user.social_media
          @social.facebook = params[:facebook]
          @social.youtube = params[:youtube]
          @social.linkedin = params[:linkedin]
          @social.twitter = params[:twitter]
          @social.instagram = params[:instagram]
          @social.spotify = params[:spotify]

          if @social.save
            render json: {
              code: 200,
              success: true,
              message: "social media added successfully",
              data: {
                "id" => @user.id,
                "website" => @user.business_profile.website,
                "facebook" => @social.facebook, 
                "youtube" => @social.youtube, 
                "linkedin" => @social.linkedin, 
                "twitter" => @social.twitter, 
                "instagram" => @social.instagram, 
                "spotify" => @social.spotify 
            }
          }
          else
            render json: {
              code: 400,
              success: false,
              message: @social.errors.full_messages,
              data: nil
            }
          end
        else
          @social = SocialMedia.new
          @social.user = @user
          @social.facebook = params[:facebook]
          @social.youtube = params[:youtube]
          @social.linkedin = params[:linkedin]
          @social.twitter = params[:twitter]
          @social.instagram = params[:instagram]
          @social.spotify = params[:spotify]

          if @social.save
            render json: {
              code: 200,
              success: true,
              message: "social media added successfully",
              data: {
                "id" => @user.id,
                "website" => @user.business_profile.website,
                "facebook" => @social.facebook, 
                "youtube" => @social.youtube, 
                "linkedin" => @social.linkedin, 
                "twitter" => @social.twitter, 
                "instagram" => @social.instagram, 
                "spotify" => @social.spotify 
            }
          }
          else
            render json: {
              code: 400,
              success: false,
              message: @social.errors.full_messages,
              data: nil
            }
          end
        end
      else
          render json: {
            code: 400,
            success: false,
            message: @business.errors.full_messages,
            data: nil
          }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "User doesnt exist",
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "user_id is required",
      data: nil
    }
  end
end

def add_phone
  if !params[:user_id].blank?
    if User.where(id: params[:user_id]).exists?
      @user = User.find(params[:user_id])
      @user.phone_number = params[:phone_number]
      @user.phone_details = params[:phone_details]
      if @user.save
      app = Assignment.where(role_id: 5).map {|assignment| assignment.user }.select { |e| e.phone_number == params[:phone_number]} 
      business = Assignment.where(role_id: 2).map {|assignment| assignment.user }.select { |e| e.phone_number == params[:phone_number]}.select {|e| e.status == "active"}
          render json: {
            code: 200,
            success: true,
            message: "Phone number added",
            data: {
              "id" => @user.id,
              "phone_number" => @user.phone_number,
              "phone_details" => jsonify_phone_details(@user.phone_details),
              user: {
                "businesses" => business,
                "app_users" => app
              }
          }
        }
      else
          render json: {
            code: 400,
            success: false,
            message: @user.errors.full_messages,
            data: nil
          }
      end
    else
      render json: {
        code: 400,
        success: false,
        message: "User doesnt exist",
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "user_id is required",
      data: nil
    }
  end
end

def link_accounts
  if !params[:phone_number].blank?
    if User.where(phone_number: params[:phone_number]).exists?
      app = Assignment.where(role_id: 5).map {|assignment| assignment.user }.select { |e| e.phone_number == params[:phone_number]} 
      business = Assignment.where(role_id: 2).map {|assignment| assignment.user }.select { |e| e.phone_number == params[:phone_number]}.select {|e| e.status == "active"}

      render json: {
        code: 200,
        success: true,
        data: {
          users: {
            "businesses" => business,
            "app_users" => app
          }
        }
      }

    else
      render json: {
        code: 400,
        success: false,
        message: "Users doesnt exist with the phone_number #{params[:phone_number]} ",
        data: nil
      }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "phone_number is required",
      data: nil
    }
  end
end

def invite_admin
  if !params[:admin_id].blank? && !params[:user_id].blank?
    @admin = User.find(params[:admin_id])
    @sender = User.find(params[:user_id])
    if(request_status(@sender, @admin)['status'] == false)
      @admin_request = @sender.admin_requests.new(admin: @admin)
      @admin_request.status = "pending"
      if @admin_request.save
        if notification = Notification.create(recipient: @admin, actor: @sender, action: get_full_name(@sender) + " sent you an admin request", notifiable: @admin_request, resource: @admin_request, url: '/admin/admin-requests', notification_type: 'web', action_type: 'admin_request')

          @pubnub = Pubnub.new(
          publish_key: ENV['PUBLISH_KEY'],
          subscribe_key: ENV['SUBSCRIBE_KEY']
          )

          @current_push_token = @pubnub.add_channels_to_push(
            push_token: @admin.device_token,
            type: 'gcm',
            add: @admin.device_token
            ).value

          payload = {
          "pn_gcm":{
            "notification": {
              "title": get_full_name(@admin),
              "body": notification.action
            },
            data: {

              "id": notification.id,
              "admin_name": get_full_name(notification.resource.user),
              "admin_id": notification.resource.user.id,
              "request_id": notification.resource.id,
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
        end
          render json:  {
            code: 200,
            success: true,
            message: "Admin request sent.",
            data:nil
          }
      else
        render json:  {
          code: 400,
          success: false,
          message: "Admin request sending failed.",
          data:nil
        }
      end
    else
        render json:  {
          code: 400,
          success: false,
          message: request_status(@sender, @admin)['message'],
          data:nil
       }
    end
  else
    render json:  {
      code: 400,
      success: false,
      message: "admin_id and user_id are required",
      data:nil
   }
  end
end

def admin_requests
  if !params[:user_id].blank?
    if User.where(id: params[:user_id]).exists?
      requests = AdminRequest.where(user_id: params[:user_id])
      @requests = []
      requests.each do |request|
        sender  = User.find(request.user_id)
        @requests << {
          "id": request.id,
          "full_name" => sender.business_profile.profile_name,
          "avatar" => sender.avatar,
          "status" => request.status,
          "user_id" => request.user_id,
          "friend_id" => request.admin_id
        }
      end
      render json: {
        code: 200,
        success: true,
        message: '',
        data: {
          requests: @requests
        }
      }
    else
      render json:  {
        code: 400,
        success: false,
        message: "user doesnt exist",
        data:nil
        }
    end
  else
    render json:  {
      code: 400,
      success: false,
      message: "user_id is required",
      data:nil
   }
  end
end

def accept_admin_request
  if !params[:request_id].blank? && !params[:user_id].blank?
    @user = User.find(params[:user_id])
    request = AdminRequest.find(params[:request_id])
    request.status = 'accepted'
      if request.save
        new_request = AdminRequest.new
        new_request.user_id = request.admin_id
        new_request.admin_id = request.user_id
        new_request.status = 'accepted'
          if new_request.save
            @notification =  Notification.where(notifiable_id: request.id).where(notifiable_type: 'AdminRequest').first
            if !@notification.blank?
             @notification.destroy
            end
              if notification = Notification.create(recipient: request.user, actor: @user, action: get_full_name(@user) + " accepted your admin request", notifiable: request, resource: request, url: '/admin/my-admins', notification_type: 'web', action_type: 'accept_admin_request')

                @pubnub = Pubnub.new(
                  publish_key: ENV['PUBLISH_KEY'],
                  subscribe_key: ENV['SUBSCRIBE_KEY']
                )
                @current_push_token = @pubnub.add_channels_to_push(
                  push_token: request.user.device_token,
                  type: 'gcm',
                  add: request.user.device_token
                  ).value

                  payload = {
                    "pn_gcm":{
                      "notification":{
                        "title": get_full_name(@user),
                        "body": notification.action
                      },
                      data: {
                        "id": notification.id,
                        "admin_name": get_full_name(notification.resource.admin),
                        "admin_id": notification.resource.admin.id,
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
              end
               render json: {
                 code: 200,
                 success: true,
                 message: "Admin request accepted.",
                 data: {
                  friend_id: request.user.id,
                  full_name: request.user.business_profile.profile_name,
                  avatar: request.user.avatar
                    }
                  }
          else
            render json: {
              code: 400,
              success: false,
              message: "Friend request acceptance failed.",
              data:nil
            }
          end
      end
  else
    render json: {
      code: 400,
      success: false,
      message: "request_id is required field.",
      data: nil
    }
  end
end

def get_device_token
  if !params[:user_id].blank?
    if User.where(id: params[:user_id]).exists?

      @user = User.find(params[:user_id])
      @user.status = "active"
      @user.save

      app = Assignment.where(role_id: 5).map {|assignment| assignment.user }.select { |e| e.id == params[:user_id]} 
      business = Assignment.where(role_id: 2).map {|assignment| assignment.user }.select { |e| e.id == params[:user_id]}.select {|e| e.status == "active"}

      @business = @user.business_profile
      @social = @user.social_media
      device_token = {
        "user_id" => @user.id,
        "email" =>  @user.email,
        "avatar" => @user.avatar,
        "phone_number" =>  @user.phone_number,
        "is_subscribed" => @user.is_subscribed,
        "device_token" => @user.device_token,
        "location" => jsonify_location(@user.location),
        "about" => @user.about,
        "profile_name" => @business.profile_name,
        "contact_name" =>  @business.contact_name,
        "display_name" =>  @business.display_name,
        "website" => @business.website,
        "description" => @business.description,
        "vat_number" =>  @business.vat_number,
        "charity_number" =>  @business.charity_number,
        "is_charity" =>  @business.is_charity,
        "youtube" =>  @social.youtube,
        "instagram" =>  @social.instagram,
        "twitter" =>  @social.twitter,
        "linkedin" =>  @social.linkedin,
        "facebook" => @social.facebook,
        "snapchat" => @social.snapchat,
        "spotify" => @social.spotify,
        "token" =>   encode(user_id: @user.id),
        "phone_details" => jsonify_phone_details(@user.phone_details),
        "link_accounts" => {
          "app_users" => app,
          "business" => business
        }
      }

      render json:  {
        code: 200,
        success: true,
        message: "Device Token",
        data: device_token
        }
    else
      render json:  {
        code: 400,
        success: false,
        message: "user doesnt exist",
        data:nil
        }
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "user is required.",
      data: nil
    }
  end
end

  def create_user
    required_fields = ['profile_name', 'contact_name','location', 'display_name', 'phone_number', 'email', 'role_id', 'password','is_charity', 'about']
    errors = []
    required_fields.each do |field|
      if params[field.to_sym].blank?
        errors.push(field + ' is required.')
      end
    end

   if errors.blank?
    registered  = false
    @user = User.new
    if params[:avatar].blank?
     @user.remote_avatar_url = get_dummy_avatar
    else
      @user.avatar = params[:avatar]
    end
      @user.phone_number = params[:phone_number]
      @user.email = params[:email]
      @user.password = params[:password]
      @user.location = params[:location]
      @user.is_subscribed = params[:is_subscribed]
      @user.about = params[:about]
      @user.mobile_user = false
      @user.uuid = generate_uuid

      user_and_profile_errors = []


      if @user.save
       setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']

       setting_name_values.each do |name|
         new_setting = Setting.create!(user: @user, name: name, is_on: true)
       end #each

        #create role
        assignment = @user.assignments.create!(role_id: params[:role_id])
      else
        @user.errors.full_messages.map { |m| user_and_profile_errors.push(m) }

      end

      @business = BusinessProfile.new

        @business.user = @user

        @business.profile_name = params[:profile_name]
        @business.contact_name = params[:contact_name]
        @business.display_name = params[:display_name]
        @business.website = params[:website]
        @business.vat_number = params[:vat_number]
        @business.charity_number = params[:charity_number]
        @business.is_charity = params[:is_charity]
        @business.stripe_state = generate_code


        if @business.save
          "do nothing"
        else
            @business.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
        end
       #Also save default setting

        @social = SocialMedia.new

        @social.user = @user

        @social.youtube = params[:youtube]
        @social.instagram = params[:instagram]
        @social.twitter = params[:twitter]
        @social.facebook = params[:facebook]
        @social.snapchat = params[:snapchat]
        @social.linkedin = params[:linkedin]

        if @social.save
          "do nothing"
        else
            @social.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
        end

        assignment = @user.assignments.create!(role_id: params[:role_id])


      if user_and_profile_errors.blank?


      profile = {
        "user_id" => @user.id,
        "email" =>  @user.email,
        "avatar" => @user.avatar,
        "phone_number" =>  @user.phone_number,
        "is_subscribed" => @user.is_subscribed,
        "device_token" => @user.device_token,
        "location" => jsonify_location(@user.location),
        "about" => @user.about,
        "profile_name" => @business.profile_name,
        "contact_name" =>  @business.contact_name,
        "display_name" =>  @business.display_name,
        "website" => @business.website,
        "vat_number" =>  @business.vat_number,
        "charity_number" =>  @business.charity_number,
        "is_charity" =>  @business.is_charity,
        "youtube" =>  @social.youtube,
        "instagram" =>  @social.instagram,
        "twitter" =>  @social.twitter,
        "linkedin" =>  @social.linkedin,
        "facebook" => @social.facebook,
        "snapchat" => @social.snapchat,
        "token" =>   encode(user_id: @user.id)
      }

      render json: {
        code: 200,
        success: true,
        message: "Registered successfully",
        data: {
          profile: profile
        }
      }
      else
        render json: {
        code: 400,
        success: false,
        message: user_and_profile_errors,
        data: nil
      }
    end

  else

    render json: {
      code: 400,
      success:false,
      message: errors,
      data: nil
    }
  end
  end

  api :POST, 'dashboard/api/v1/users', 'Create new user'
  # param :id, :number, :desc => "ID of the user", :required => true
  # param :type, :number, :desc => "Role ID (1,2,3)", :required => true
  # param :profile, String, :desc => "Profile Name", :required => true
  # param :contact_name, String, :desc => "Contact Name", :required => true
  # param :address, String, :desc => "Address", :required => true
  # param :vat_number, :number, :desc => "Vat number", :required => true
  # param :website, String, :desc => "website", :required => true
  # param :is_charity, ['True', 'False'], :desc => "User ID", :required => true
  # param :avatar, String, :desc => "Avatar"
  # param :phone_number, String
  # param :email, String, :desc => "Email"
  # param :web_user, ['True', 'False']
  #param :password, String, :desc => "Password"

  def update_user
    if !params[:user_id].blank?
         required_fields = ['profile_name', 'contact_name','location', 'display_name', 'phone_number', 'email', 'password','is_charity', 'about']
          errors = []
          required_fields.each do |field|
            if params[field.to_sym].blank?
              errors.push(field + ' is required.')
            end
          end

    if errors.blank?
          registered  = false
          @user = User.find(params[:user_id])
          if params[:avatar].blank?
           @user.remote_avatar_url = get_dummy_avatar
          else
            @user.avatar = params[:avatar]
          end
            @user.phone_number = params[:phone_number]
            @user.email = params[:email]
            @user.password = params[:password]
            @user.location = params[:location]
            @user.is_subscribed = params[:is_subscribed]
            @user.about = params[:about]
            @user.mobile_user = false

            user_and_profile_errors = []


            if @user.save
             setting_name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']

               setting_name_values.each do |name|
                 new_setting = Setting.create!(user: @user, name: name, is_on: true)
               end #each

              #create role
              
            else
              @user.errors.full_messages.map { |m| user_and_profile_errors.push(m) }

            end
       
            @business = @user.business_profile

              @business.profile_name = params[:profile_name]
              @business.contact_name = params[:contact_name]
              @business.display_name = params[:display_name]
              @business.website = params[:website]
              @business.vat_number = params[:vat_number]
              @business.charity_number = params[:charity_number]
              @business.is_charity = params[:is_charity]
              @business.stripe_state = generate_code


             if @business.save
              "do nothing"
             else
                  @business.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
             end
               #Also save default setting

              @social = @user.social_media

              @social.youtube = params[:youtube]
              @social.instagram = params[:instagram]
              @social.twitter = params[:twitter]
              @social.facebook = params[:facebook]
              @social.snapchat = params[:snapchat]
              @social.linkedin = params[:linkedin]

              if @social.save
                "do nothing"
              else
                  @social.errors.full_messages.map { |m| user_and_profile_errors.push(m) }
              end


          if user_and_profile_errors.blank?
            profile = {
              "user_id" => @user.id,
              "email" =>  @user.email,
              "avatar" => @user.avatar,
              "phone_number" =>  @user.phone_number,
              "is_subscribed" => @user.is_subscribed,
              "device_token" => @user.device_token,
              "location" => jsonify_location(@user.location),
              "about" => @user.about,
              "profile_name" => @business.profile_name,
              "contact_name" =>  @business.contact_name,
              "display_name" =>  @business.display_name,
              "website" => @business.website,
              "vat_number" =>  @business.vat_number,
              "charity_number" =>  @business.charity_number,
              "is_charity" =>  @business.is_charity,
              "youtube" =>  @social.youtube,
              "instagram" =>  @social.instagram,
              "twitter" =>  @social.twitter,
              "linkedin" =>  @social.linkedin,
              "facebook" => @social.facebook,
              "snapchat" => @social.snapchat,
              "token" =>   encode(user_id: @user.id)
            }

            render json: {
              code: 200,
              success: true,
              message: "User successfully updated",
              data: {
                profile: profile
              }
            }
            else
              render json: {
              code: 400,
              success: false,
              message: user_and_profile_errors,
              data: nil
            }
          end

        else

          render json: {
            code: 400,
            success:false,
            message: errors,
            data: nil
          }
        end
      
  else
          render json: {
            code: 400,
            success:false,
            message: "user_id is required",
            data: nil
          }

  end
end

private

# def admin_requests
#   @requests = User.admin_requests(current_user)
#   #@outgoing = current_user.friend_requests
#   render :admin_requests  
# end

    def request_status(sender,recipient)
      admin_request = AdminRequest.where(user_id: sender.id).where(admin_id: recipient.id).first
      if admin_request
       if admin_request.status == 'pending' || admin_request.status == 'accepted'
        status = {
          "message" => "You have already sent admin request to #{get_full_name(recipient)} ",
          "status" => true
         }
       end
      elsif AdminRequest.where(user_id: recipient.id).where(admin_id: sender.id).first
        status = {
           "message" => "#{get_full_name(recipient)} already sent you an admin request ",
           "status" => true
         }
      else
          status = {
            "message" => "",
            "status" => false
          }
      end
      status
  end
end #class
