class ProfessionalsController < ApplicationController
  def show
    @professional = Professional.find(params[:id])
  end
end
