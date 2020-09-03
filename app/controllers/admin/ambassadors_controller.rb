class Admin::AmbassadorsController < Admin::AdminMasterController

  def ambassadors_requets
    @requests = current_user.business_ambassador_requests.order(id: 'DESC')
    render :ambassadors
  end

  def approve
    ambassador = AmbassadorRequest.find(params[:id])
    ambassador.status = 'accepted'
    ambassador.user.profile.update!(is_ambassador: true)
    if ambassador.save
      #create business activity
      create_activity(current_user, " approved #{User.get_full_name(ambassador.user)} as an ambassador ", ambassador, 'AmbassadorRequest', '', '', 'post', 'approved_ambassador')
      create_activity(ambassador.user, "become ambassador ", ambassador, 'AmbassadorRequest', '', '', 'post', 'become_ambassador')
       #create ambassador activity
      flash[:notice] = "Ambassador successfully approved."
      redirect_to admin_ambassadors_path 
    else
      flash[:alert_danger] = "Ambassador approval failed."
      redirect_to admin_ambassadors_path 
    end
  end

  def remove
    ambassador = AmbassadorRequest.find(params[:id])
    ambassador.status = 'rejected'
    ambassador.user.profile.update!(is_ambassador: false)
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
