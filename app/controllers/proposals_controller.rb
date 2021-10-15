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

  private
  def proposal_params
    params.require(:proposal).permit(:message, :value_per_hour, :hours_per_week, 
      :finish_date)
  end
end

# :message, null: false, default: ""
# :value_per_hour, null: false, default: 0
# :hours_per_week, null: false, default: 1
# :finish_date, null: false
# :status, null: false, default: 0
# params.require(:project).permit(:title, :description, :desired_abilities,
#       :value_per_hour, :due_date, :remote)
