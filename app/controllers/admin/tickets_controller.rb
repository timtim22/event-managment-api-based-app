class Admin::TicketsController < Admin::AdminMasterController

  def index
    @tickets = current_user.tickets.order(id: 'DESC')
  end

  def show
    @ticket = Ticket.find(params[:id])
  end

  def new
    @ticket = Ticket.new
  end

  def edit
    @ticket = Ticket.find(params[:id])
  end

  def update
    ids = params['event_ids']
    success = false
    if !ids.blank?
    ids.each do |id|
      @ticket = Ticket.find_by(event_id: id)
      @ticket.title = params[:title]
      @ticket.price = params[:price]
      @ticket.quantity = params[:quantity]
      @ticket.event_id = id
      @ticket.user_id = current_user.id
      @ticket.redeem_code = generate_code
      @ticket.per_head = params[:per_head]
      if @ticket.save
        create_activity("updated pass", @ticket, "Pass", admin_pass_path(@ticket),@ticket.title, 'patch')
        success = true
      else
        success = false
      end
    end #each

    if success
      flash[:notice] = "Ticket updated successfully."
      redirect_to admin_tickets_path
    else
        render :edit
    end
  else
    flash.now[:alert_danger] = "No event is selected."
    render :new
  end
   
  end


  def create
    @ticket = Ticket.new #instantiated to avoid undefine error in case of form errors
    ids = params['event_ids']
    if !ids.blank?
    success = false
    ids.each do |id|
      @ticket = Ticket.new
      @ticket.title = params[:title]
      @ticket.price = params[:price]
      @ticket.quantity = params[:quantity]
      @ticket.event_id = id
      @ticket.user_id = current_user.id
      @ticket.redeem_code = generate_code
      @ticket.per_head = params[:per_head]
      if @ticket.save
        success = true
      else
        success = false
      end
    end #each

    if success
      flash[:notice] = "Ticket created successfully."
      redirect_to admin_tickets_path
    else
        render :new
    end
  else
    flash.now[:alert_danger] = "No event is selected."
    render :new
  end
   
  end


  def destroy
    @ticket = Ticket.find(params[:id])
    if @ticket.destroy
      create_activity("deleted ticket", @ticket, "Ticket", '', @ticket.title, 'delete')
      redirect_to admin_tickets_path, notice: "Ticket deleted successfully."
    else
      flash[:alert_danger] = "Ticket deletetion failed."
      redirect_to admin_tickets_path
    end
  end


  private
   def pass_params
    params.permit(:title,:description, :validity,:user_id)
   end

   def generate_code
    code = SecureRandom.hex
   end
end
