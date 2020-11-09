class Admin::CategoriesController < Admin::AdminMasterController

  before_action :set_category, only: ['edit','update','destroy','show']

 def index
  @categories = Category.order(:created_at => 'DESC').page(params[:page])
 end


 def new
  @category = Category.new
 end

 def create
   @category = Category.new(category_params)
   if @category.save
     flash[:notice] = "Category created successfully."
     redirect_to admin_categories_path
   else
    render :new
   end
 end

 def show
 end


 def edit
 end

 def update
  if @category.update!(category_params)
    flash[:notice] = "Category updated successfully."
    redirect_to admin_categories_path
  else
   flash[:alert_danger] = "Category update failed."
   redirect_to admin_categories_path
  end
 end


 def destroy
  if @category.destroy
    flash[:notice] = "Category deleted successfully."
    redirect_to admin_categories_path
  else
   flash[:alert_danger] = "Category deletion failed."
   redirect_to admin_categories_path
  end

 end


 private

 def set_category
  @category = Category.find(params[:id])
 end

 def category_params
  params.permit(:name, :icon, :color_code,:uuid)
 end


end
