class Admin::NotificationsController < Admin::AdminMasterController

  def index
    @notifications = Notification.where(recipient: current_user).where(notification_type: 'web').or(Notification.where(recipient: current_user).where(notification_type: 'mobile_web')).recent
  end

  def mark_as_read
    @notifications = Notification.where(recipient: current_user).unread
    @notifications.update_all(read_at: Time.zone.now)
    render json: {success: true}
  end

  def clear_notifications
    @notifications = current_user.notifications
    if @notifications.destroy_all
      render json: {
        success: true,
        message: "Notification cleared successfully."
      }

    else
      render json: {
        success: false,
        message: "Notification deletion failed."
      }
    end
  end

  def get_notifications_count
    @count = current_user.notifications.unread.size
    render json: {
      code: 200,
      success: true,
      messge: '',
      data: {
        count: @count
      }
    }
  end

end
