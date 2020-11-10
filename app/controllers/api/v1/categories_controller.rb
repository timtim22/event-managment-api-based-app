class Api::V1::CategoriesController < Api::V1::ApiMasterController

  def index
    categories = Category.all
    render json: {
      code: 200,
      success: true,
      message: '',
      data: {
        categories: categories
      }
    }
  end
end
