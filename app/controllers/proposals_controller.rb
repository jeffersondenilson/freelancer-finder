class ProposalsController < ApplicationController
  before_action :authenticate_professional!, only: %i[new create edit update
                                                      cancel]
  before_action :verify_duplicated_proposal, only: %i[new create]
  before_action :verify_refused_proposal, only: %i[edit update]
  before_action :authenticate_user!, only: %i[refuse]
  before_action :should_authenticate!, only: :destroy

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

  def edit
  end

  def update
    if @proposal.update(proposal_params)
      flash[:notice] = 'Proposta atualizada com sucesso'
      redirect_to my_projects_path
    else
      render :edit
    end
  end

  def cancel
    @proposal = current_professional.proposals.find(params[:proposal_id])

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

  def verify_duplicated_proposal
    if current_professional.not_canceled_proposals
                           .find_by(project_id: params[:project_id])
      flash[:alert] = 'Você já fez uma proposta nesse projeto'
      redirect_to project_path(params[:project_id])
    end
  end

  def verify_refused_proposal
    @proposal = current_professional.proposals.find(params[:id])

    if @proposal.refused?
      flash[:alert] = 'Esta proposta não pode ser editada'
      redirect_to @proposal.project
    end
  end

  def cancel_reason_params
    params[:proposal][:cancel_reason] || ''
  rescue StandardError
    ''
  end

  def professional_cancel_proposal
    @proposal = current_professional.proposals.find(params[:id])

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
