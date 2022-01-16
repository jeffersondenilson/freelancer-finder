class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

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
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: %i[name full_name birth_date education description experience
               abilities profile_picture_url]
    )
  end

  def should_authenticate!
    return if professional_signed_in? || user_signed_in?

    flash[:alert] = 'Você deve estar logado.'
    redirect_to root_path
  end

  def redirect_professional_to_complete_profile
    return if current_professional.completed_profile?

    redirect_to edit_professional_registration_path(current_professional)
  end

  def verify_duplicated_or_refused_proposal
    proposal = current_professional
               .not_canceled_proposals
               .find_by(project_id: params[:project_id])

    return unless proposal

    flash[:alert] = 'Você já fez uma proposta nesse projeto'
    if proposal.refused?
      flash[:alert] = 'Você já tem uma proposta recusada nesse projeto'
    end

    redirect_to project_path(params[:project_id])
  end

  def verify_refused_proposal_modification
    @proposal = current_professional.proposals.find(
      params[:id] || params[:proposal_id]
    )

    return unless @proposal.refused?

    flash[:alert] = 'Propostas recusadas não podem ser alteradas'
    redirect_to @proposal.project
  end

  def render_not_found(_exception)
    render file: Rails.root.join('public/404.html'), status: :not_found
  end
end
