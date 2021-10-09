class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.author = current_user

    if @project.save
      flash[:notice] = 'Projeto salvo com sucesso'
      redirect_to @project
    else
      render :new
    end
  end

  def my_projects
    @projects = current_user.projects
  end

  private
  def project_params
    params.require(:project).permit(:title, :description, :desired_abilities,
      :value_per_hour, :due_date, :remote)
  end
end
