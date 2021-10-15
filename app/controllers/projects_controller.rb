class ProjectsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update]
  before_action :authenticate_professional!, only: [:index, :search, :my_projects]
  before_action :should_authenticated!, only: :show

  def index
    @projects = Project.all
  end

  def search
    # title = Project.arel_table[:title]
    # description = Project.arel_table[:description]
    # @projects = Project.where( title.matches "%#{params[:query]}%" )
    #   .or Project.where description.matches "%#{params[:query]}%"

    query = ActiveRecord::Base.sanitize_sql_like(params[:query])
    @projects = Project.where("title LIKE :query OR description LIKE :query",
      query: "%#{query}%")

    render :index
  end

  def show
    @project = nil

    if professional_signed_in?
      @project = Project.find_by(id: params[:id])
      @proposal = @project.proposals.find_by(professional_id: current_professional.id)
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

  def my_projects
    # @projects = 
    @proposals = current_professional.proposals
  end

  private
  def project_params
    params.require(:project).permit(:title, :description, :desired_abilities,
      :value_per_hour, :due_date, :remote)
  end

  # TODO: fix cross model visits!
  def should_authenticated!
    return if professional_signed_in? || user_signed_in?

    flash[:alert] = "Você deve estar logado."
    redirect_to root_path
  end
end
