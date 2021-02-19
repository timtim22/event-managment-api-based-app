class Admin::AmbassadorsController < Admin::AdminMasterController

  def ambassadors_requets
    @requests = current_user.business_ambassador_requests.order(id: 'DESC')
    render :ambassadors
  end

  def approve
    if approve_ambassador(current_user,params[:id])
       #notify ambassador about approval

      flash[:notice] = "Ambassador successfully approved."
      redirect_to admin_ambassadors_path
    else
      flash[:alert_danger] = "Ambassador approval failed."
      redirect_to admin_ambassadors_path
    end
  end

  def remove
    ambassador_request = AmbassadorRequest.find(params[:id])
    ambassador_request.status = 'rejected'
    #ambassador.user.profile.update!(is_ambassador: false) to be handled next
    if ambassador.save
      flash[:notice]  = "Ambassador successfully removed."
      redirect_to admin_ambassadors_path
    else
      flash[:alert_danger] = "Ambassador removal failed."
      redirect_to admin_ambassadors_path
    end
  end

  def view_ambassador
    @ambassador = User.find(params[:id])
    @request_id = params[:r_id]
    render :view
  end

end
