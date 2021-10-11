# TODO: apagar?
module ProfessionalProfile
  extend ActiveSupport::Concern
  included do
    before_action :completed_profile?
  end

  protected
  def completed_profile?
    if professional_signed_in? && !current_professional.completed_profile?
      redirect_to edit_professional_registration_path(current_professional) and return
    end
  end
end
