class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  include Devise::Controllers::Helpers
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  add_flash_types :success, :danger

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def fetch_libraries
    @search_libraries = []

    if params[:search].present?
      @search_libraries = Library.where("formal LIKE ? OR address LIKE ?",
                                  "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end
end
