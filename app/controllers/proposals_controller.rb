class ProposalsController < ApplicationController
  before_action :authenticate_professional!

  def new
    @project = Project.find(params[:project_id])
    @proposal = Proposal.new
  end

  def create
    @proposal = Proposal.new(proposal_params)
    @proposal.project_id = params[:project_id]
    @proposal.professional = current_professional

    if @proposal.save
      redirect_to project_path(params[:project_id])
    else
      @project = Project.find(params[:project_id])
      render :new
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

    # if @proposal.cancel!(params[:proposal][:cancel_reason])
    #   flash[:notice] = 'Proposta cancelada com sucesso'
    # else
    #   flash[:alert] = 'Não foi possível cancelar a proposta'
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
end