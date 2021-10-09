class ProjectsController < ApplicationController
  # TODO: só mostrar e editar projetos criados pelo usuário
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

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    # p project_params

    if @project.update(project_params)
      flash[:notice] = 'Projeto atualizado com sucesso'
      redirect_to @project
    else
      p @project.errors.full_messages
      render :edit
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
