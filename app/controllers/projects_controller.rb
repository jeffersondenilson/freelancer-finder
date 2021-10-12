class ProjectsController < ApplicationController
  before_action :authenticate_user!,
    only: [:show, :new, :create, :edit, :update],
    unless: :professional_signed_in?
  before_action :authenticate_professional!,
    only: [:index, :show],
    unless: :user_signed_in?

  def index
    @projects = Project.all
  end

  def show
    @project = nil

    if professional_signed_in?
      @project = Project.find_by(id: params[:id])
    elsif user_signed_in?
      @project = Project.find_by(id: params[:id], creator: current_user)
    end

    if @project.nil?
      flash[:alert] = 'O projeto não foi encontrado'
      redirect_to root_path
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.creator = current_user

    if @project.save
      flash[:notice] = 'Projeto salvo com sucesso'
      redirect_to @project
    else
      render :new
    end
  end

  def edit
    @project = Project.find_by(id: params[:id], creator: current_user)

    if @project.nil?
      flash[:alert] = 'O projeto não foi encontrado'
      redirect_to root_path
    end
  end

  def update
    @project = Project.find_by(id: params[:id], creator: current_user)

    if @project.nil?
      flash[:alert] = 'O projeto não foi encontrado'
      redirect_to root_path and return
    end

    if @project.update(project_params)
      flash[:notice] = 'Projeto atualizado com sucesso'
      redirect_to @project
    else
      render :edit
    end
  end

  private
  def project_params
    params.require(:project).permit(:title, :description, :desired_abilities,
      :value_per_hour, :due_date, :remote)
  end
end
