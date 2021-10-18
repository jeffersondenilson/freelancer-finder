module Accessible
  extend ActiveSupport::Concern
  included do
    before_action :check_user
  end

  protected
  def check_user
    if current_professional
      flash.clear
      redirect_to(authenticated_professional_root_path) and return
    elsif current_user
      flash.clear
      redirect_to(authenticated_user_root_path) and return
    end
  end
end
