class Dashboard::Api::V1::Users::UsersController < Dashboard::Api::V1::ApiMasterController
  before_action :authorize_request, except: ['create_user', 'business_type', 'add_image', 'add_details', 'add_login', 'add_social', 'add_phone', 'link_accounts' ]
  before_action :checkout_logout, except: ['create_user', "business_type", 'add_image', 'add_details', 'add_login', 'add_social', 'add_phone', 'link_accounts']
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
          profile = {
              "user_id" => @user.id,
              "email" =>  @user.email,
              "avatar" => @user.avatar,
              "phone_number" =>  @user.phone_number,
              "password" => @user.password,
              "followers_count" => @user.followers.size,
              "address" => jsonify_location(@user.location),
              "is_subscribed" => @user.is_subscribed,
              "device_token" => @user.device_token,
              "about" => @user.about,
              "profile_name" => @user.business_profile.profile_name,
              "contact_name" => @user.business_profile.contact_name,
              "display_name" => @user.business_profile.display_name,
              "website" => @user.business_profile.website,
              "vat_number" => @user.business_profile.vat_number,
              "charity_number" => @user.business_profile.charity_number,
              "is_charity" => @user.business_profile.is_charity,
              "youtube" => @user.social_media.youtube,
              "instagram" => @user.social_media.instagram,
              "linkedin" => @user.social_media.linkedin,
              "facebook" => @user.social_media.facebook,
              "twitter" => @user.social_media.twitter
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
      if @user.save
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
              "location" => @user.location,
              "description" => @user.description 
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
        if !User.where(email: params[:email]).exists?
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
      if @user.save
          render json: {
            code: 200,
            success: true,
            message: "Phone number added",
            data: {
              "id" => @user.id,
              "phone_number" => @user.phone_number
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
      app = Assignment.where(role_id: 5).map {|assignment| assignment.user }.select { |e| e.phone_number == params[:phone_number] } 
      business = Assignment.where(role_id: 2).map {|assignment| assignment.user }.select { |e| e.phone_number == params[:phone_number] } 

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
        message: "Users doesnt exist with the phone_number",
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
end #class
