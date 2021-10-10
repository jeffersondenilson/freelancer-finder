class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_professional_to_complete_profile,
    :if => proc {|c| !devise_controller? && professional_signed_in?}

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def redirect_professional_to_complete_profile
    if !current_professional.completed_profile
      redirect_to edit_professional_registration_path(current_professional)
    end
  end
end
