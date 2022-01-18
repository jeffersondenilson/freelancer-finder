class ProposalsController < ApplicationController
  before_action :should_authenticate!, only: :destroy
  before_action :authenticate_professional!, only: %i[new create edit update
                                                      cancel]
  before_action :authenticate_user!, only: %i[refuse approve]
  before_action :verify_duplicated_or_refused_proposal, only: %i[new create]
  before_action :verify_refused_proposal_modification,
                only: %i[edit update cancel destroy],
                if: :professional_signed_in?

  def new
    @project = Project.find(params[:project_id])
    @proposal = Proposal.new
  end

  def create
    @project = Project.find(params[:project_id])

    @proposal = Proposal.new(
      **proposal_params, project: @project, professional: current_professional
    )

    if @proposal.save
      redirect_to project_path(@project.id),
                  notice: 'Proposta criada com sucesso'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @proposal.update(proposal_params)
      flash[:notice] = 'Proposta atualizada com sucesso'
      redirect_to my_projects_path
    else
      render :edit
    end
  end

  def cancel
    if @proposal.pending?
      @proposal.cancel!
      redirect_to my_projects_path, notice: 'Proposta cancelada com sucesso'
    elsif !@proposal.can_cancel_at_current_date?
      @proposals = current_professional.not_canceled_proposals
                                       .order(:updated_at)
      render 'projects/my_projects'
    end
  end

  def refuse
    @proposal = Proposal.find_by!(id: params[:proposal_id],
                                  project: [current_user.projects])
  end

  def approve
    proposal = Proposal.find_by!(id: params[:proposal_id],
                                  project: [current_user.projects])
    if proposal.approve!
      flash[:notice] = 'Proposta aprovada com sucesso. '\
        "Agora você pode trocar mensagens com #{proposal.professional.name}"
    else
      flash[:alert] = 'Não foi possível aprovar a proposta'
    end

    redirect_to project_path(proposal.project)
  end

  def destroy
    if professional_signed_in?
      professional_cancel_proposal
    elsif user_signed_in?
      user_refuse_proposal
    end
  end

  private

  def proposal_params
    params.require(:proposal).permit(:message, :value_per_hour, :hours_per_week,
                                     :finish_date)
  end

  def cancel_reason_params
    params[:proposal][:cancel_reason] || ''
  rescue StandardError
    ''
  end

  def professional_cancel_proposal
    if @proposal.cancel!(cancel_reason_params)
      flash[:notice] = 'Proposta cancelada com sucesso'
    else
      @proposals = current_professional.not_canceled_proposals
                                       .order(:updated_at)
      render 'projects/my_projects' and return
    end

    redirect_to my_projects_path
  end

  def user_refuse_proposal
    @proposal = Proposal.find_by!(id: params[:id],
                                  project: [current_user.projects])

    if @proposal.refuse!(params[:proposal][:refuse_reason])
      flash[:notice] = 'Proposta recusada com sucesso'
    else
      flash[:alert] = 'Não é possível recusar essa proposta'
    end

    redirect_to project_path(@proposal.project)
  end
end
