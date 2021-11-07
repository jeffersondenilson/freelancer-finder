class ProposalsController < ApplicationController
  before_action :authenticate_professional!
  before_action :verify_duplicated_proposal, only: %i[new create]

  def new
    @project = Project.find(params[:project_id])
    @proposal = Proposal.new
  end

  def create
    @project = Project.find_by(id: params[:project_id])

    return redirect_to root_path, alert: 'Projeto não encontrada' if
      @proposal.nil?

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
    @proposal = current_professional.proposals.find_by(id: params[:id])

    redirect_to my_projects_path, alert: 'Proposta não encontrada' if
      @proposal.nil?
  end

  def update
    @proposal = current_professional.proposals.find_by(id: params[:id])

    return redirect_to my_projects_path, alert: 'Proposta não encontrada' if
      @proposal.nil?

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

  def destroy
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

  def cancel_reason_params
    params[:proposal][:cancel_reason] || ''
  rescue StandardError
    ''
  end
end
