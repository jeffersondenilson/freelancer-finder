class Professional < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  validates :full_name, :birth_date, :education, :description, :abilities, 
    :profile_picture_url, presence: true, on: :update

  before_update :set_completed_profile

  private
  def set_completed_profile
    self.completed_profile = true
  end
end

# :full_name, :string, default: ""
# :birth_date, :date, default: ""
# :education, :text, default: ""
# :description, :text, default: ""
# :experience, :text, default: ""
# :abilities, :text, default: ""
# :profile_picture_url, :string, default: ""
# :completed_profile, :boolean, default: false
