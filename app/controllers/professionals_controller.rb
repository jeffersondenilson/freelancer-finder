class ProfessionalsController < ApplicationController
  before_action :authenticate_user!, only: :show

  def show
    @professional = Professional.find(params[:id])
  end
end
