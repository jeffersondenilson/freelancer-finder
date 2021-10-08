class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def my_projects
    @projects = current_user.projects
  end
end
