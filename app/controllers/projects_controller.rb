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
      @project = Project.find_by(id: params[:id])
      @proposal = current_professional.not_canceled_proposals
                                      .find_by(project_id: params[:id])
    elsif user_signed_in?
      @project = Project.find_by(id: params[:id], creator: current_user)
    end

    redirect_to root_path, alert: 'O projeto não foi encontrado' if
      @project.nil?
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

    redirect_to root_path, alert: 'O projeto não foi encontrado' if
      @project.nil?
  end

  def update
    @project = Project.find_by(id: params[:id], creator: current_user)

    return redirect_to root_path, alert: 'O projeto não foi encontrado' if
      @project.nil?

    if @project.update(project_params)
      flash[:notice] = 'Projeto atualizado com sucesso'
      redirect_to @project
    else
      render :edit
    end
  end

  def my_projects
    # @projects =
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
end
