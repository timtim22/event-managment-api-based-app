class Api::V1::SettingsController < Api::V1::ApiMasterController
  before_action :authorize_request
 
  def update_global_setting
   if !params[:is_on].blank? && !params[:name].blank?
    name_values = ['all_chat_notifications','event_notifications','special_offers_notifications','passes_notifications','competitions_notifications','location']
   if name_values.include? params[:name] 
      @setting = Setting.where(user_id: request_user.id).where(name: params[:name]).first
    if @setting.blank? # create new setting if doesn't exit.
      if new_setting = Setting.create!(user_id: request_user.id, name: params[:name], is_on: params[:is_on])
        render json: {
          code: 200,
          success: true,
          message: "#{params[:name]} setting successfully updated.",
          data: nil
        }
      else
        render json:  {
          code: 400,
          success: false,
          message: new_setting.errors.full_messages,
          data: nil
        }
      end
    else
      if setting = @setting.update!(is_on: params[:is_on])
        render json: {
          code: 200,
          success: true,
          message: "#{params[:name]} setting successfully updated.",
          data: nil
        }
      else
        render json: {
          code: 400,
          success: false,
          message: setting.errors.full_messages,
          data: nil
        }
      end
    end
  else
    render json: {
      code: 400,
      success: false,
      message: "name value is incorrect.",
      data: nil
      }
  end
   else
    render json: {
      code: 400,
      success: false,
      message: "is_on and name fields are required.",
      data: nil
      }
   end
  end



  def update_user_setting
     #specific setting
     settings = ['mute_chat','mute_notifications','block', 'remove_offers','remove_competitions','remove_passes']
    if !params[:setting_name].blank? && !params[:resource_id].blank? && !params[:resource_type].blank?  && !params[:is_on].blank?
       if settings.include? params[:setting_name]
         #if user doesn't have any setting then create it first (new user)
         setting = request_user.user_settings.where(name: params[:setting_name]).where(resource_id: params[:resource_id]).where(resource_type: params[:resource_type]).first
        
         if setting.blank? 
            if setting = request_user.user_settings.create!(name: params[:setting_name], resource_id: params[:resource_id], resource_type: params[:resource_type], is_on: params[:is_on], blocked_at: Time.zone.now)

            #in order to acheive bi directionsl blocking
            if(params[:setting_name] == 'block' && params[:resource_type] == 'User')
               blockee = User.find(params[:resource_id])
               setting_reverse = blockee.user_settings.create!(name: params[:setting_name], resource_id: request_user.id, resource_type: params[:resource_type], is_on: params[:is_on])
             end 
            
              render json:  {
                code: 200,
                success: true,
                message: "Setting successfully created.",
                data: nil
              }
            else
              render json: {
                code: 400,
                success: false,
                message: setting.errors.full_messages,
                data: nil
              }
            end
         else
             if setting.update!(is_on: params[:is_on], blocked_at: Time.zone.now)
              if(params[:setting_name] == 'block' && params[:resource_type] == 'User')
              setting_reverse = UserSetting.where(user_id: blockee.id).where(resource_id: request_user.id).where(resource_type:  params[:resource_type]).where(name: params[:setting_name]).first
               setting_reverse.update!(is_on: params[:is_on])
              end
              render json:  {
                code: 200,
                success: true,
                message: "Setting successfully updated.",
                data: nil
              }
            else
              render json: {
                code: 400,
                success: false,
                message: setting.errors.full_messages,
                data: nil
              }
            end

          end #else
          else
            render json: {
              code: 400,
              success: false,
              message: " Please choose one of the recommended setting names i.e 'mute_chat','mute_notifications','block', 'remove_offers', 'remove_competitions','remove_passes'",
              data: nil
            }
          end

          else
            render json: {
              code: 400,
              success: false,
              message: "setting_name, resource_id, resource_type and is_on are required fields.",
              data: nil
            }
          end
        end

end
