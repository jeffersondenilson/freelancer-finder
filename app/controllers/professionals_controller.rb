class ProfessionalsController < ApplicationController
  before_action :authenticate_user!, only: :show

  def show
    @professional = Professional.find(params[:id])
    @proposals = Proposal.where(project: [current_user.projects],
                                professional: @professional, status: :pending)
  end
end
