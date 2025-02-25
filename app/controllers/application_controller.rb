class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  add_flash_types :success, :danger

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def set_search
    @q = Library.ransack(params[:q])
    @libraries = @q.result(distinct: true).order(created_at: :desc).page(params[:page]).per(10)
    render template: "libraries/index"
  end
end
