class ApplicationController < ActionController::Base
  # TODO: adicionar rescue_from para 404

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :redirect_professional_to_complete_profile,
                if: proc { |_c| !devise_controller? && professional_signed_in? }

  before_action :configure_permitted_parameters_for_professional_update,
                if: proc { |_c| devise_controller? && professional_signed_in? }

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def configure_permitted_parameters_for_professional_update
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name full_name
                                                                birth_date education description experience abilities
                                                                profile_picture_url])
  end

  def redirect_professional_to_complete_profile
    return if current_professional.completed_profile?
    redirect_to edit_professional_registration_path(current_professional)
  end
end
