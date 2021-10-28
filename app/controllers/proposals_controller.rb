class ProposalsController < ApplicationController
  before_action :authenticate_professional!
  before_action :verify_duplicated_proposal, only: [:new, :create]

  def new
    @project = Project.find(params[:project_id])
    @proposal = Proposal.new
  end

  def create
    @project = Project.find_by(id: params[:project_id])

    if @project.nil?
      flash[:alert] = 'Projeto não encontrado'
      redirect_to root_path and return
    end

    @proposal = Proposal.new(proposal_params)
    @proposal.project = @project
    @proposal.professional = current_professional

    if @proposal.save
      redirect_to project_path(params[:project_id])
    else
      render :new
    end
  end

  def edit
    @proposal = current_professional.proposals.find_by(id: params[:id])

    if @proposal.nil?
      flash[:alert] = 'Proposta não encontrada'
      redirect_to my_projects_path
    end
  end

  def update
    @proposal = current_professional.proposals.find_by(id: params[:id])

    if @proposal.nil?
      flash[:alert] = 'Proposta não encontrada'
      redirect_to my_projects_path and return
    end

    if @proposal.update(proposal_params)
      flash[:notice] = 'Proposta atualizada com sucesso'
      redirect_to my_projects_path
    else
      render :edit
    end
  end

  def cancel
    @proposal = current_professional.proposals.find(params[:proposal_id])

    if !@proposal.can_cancel_at_current_date?
      flash[:alert] = @proposal.errors.full_messages_for(:approved_at)[0]
      redirect_to my_projects_path
    end
  end

  def destroy
    @proposal = current_professional.proposals.find(params[:id])

    # TODO: usar metodo cancel!
    # if @proposal.cancel!(params[:proposal][:cancel_reason])
    #   flash[:notice] = 'Proposta cancelada com sucesso'
    # else
    #   flash[:alert] = @proposal.errors.full_messages_for(:approved_at)[0] || 
    #     'Não foi possível cancelar a proposta'
    # end

    # redirect_to my_projects_path

    if @proposal.pending?
      @proposal.canceled_pending!
    elsif @proposal.can_cancel_at_current_date?
      @proposal.canceled_approved!
      @proposal.proposal_cancelation = ProposalCancelation
        .new(cancel_reason: params[:proposal][:cancel_reason])
    else
      flash[:alert] = @proposal.errors.full_messages_for(:approved_at)[0]
      redirect_to my_projects_path and return
    end

    if @proposal.save
      flash[:notice] = 'Proposta cancelada com sucesso'
    else
      flash[:alert] = 'Não foi possível cancelar a proposta'
    end

    redirect_to my_projects_path
  end

  private
  def proposal_params
    params.require(:proposal).permit(:message, :value_per_hour, :hours_per_week, 
      :finish_date)
  end

  def verify_duplicated_proposal
    if current_professional.proposals.find_by(project_id: params[:project_id])
      flash[:alert] = 'Você já fez uma proposta nesse projeto'
      redirect_to project_path(params[:project_id])
    end
  end
end
