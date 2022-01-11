class ProjectsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update]
  before_action :authenticate_professional!, only: %i[index search my_projects]
  before_action :should_authenticate!, only: :show

  def index
    @projects = Project.all
  end

  def search
    query = ActiveRecord::Base.sanitize_sql_like(params[:query])
    @projects = Project.where('title LIKE :query OR description LIKE :query',
                              query: "%#{query}%")

    render :index
  end

  def show
    if professional_signed_in?
      find_project_and_proposals_for_professional
    elsif user_signed_in?
      find_project_and_proposals_for_user
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
    @project = current_user.projects.find(params[:id])
  end

  def update
    @project = current_user.projects.find(params[:id])

    if @project.update(project_params)
      flash[:notice] = 'Projeto atualizado com sucesso'
      redirect_to @project
    else
      render :edit
    end
  end

  def my_projects
    @proposals = current_professional.not_canceled_proposals
                                     .order(updated_at: :desc)
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, :desired_abilities,
                                    :value_per_hour, :due_date, :remote)
  end

  def should_authenticate!
    return if professional_signed_in? || user_signed_in?

    flash[:alert] = 'Você deve estar logado.'
    redirect_to root_path
  end

  def find_project_and_proposals_for_professional
    @project = Project.find(params[:id])
    @proposal = current_professional.not_canceled_proposals
                                    .find_by(project_id: params[:id])
  end

  def find_project_and_proposals_for_user
    @project = current_user.projects.find(params[:id])
    @proposals = @project.proposals.where.not(status: :canceled_pending)
  end
end
