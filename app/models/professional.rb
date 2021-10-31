class Professional < ApplicationRecord
  has_many :proposals
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  # TODO: metodo customizado para validar e completar perfil?
  # https://www.dan-manges.com/blog/action-dependent-validations-and-why-on-update-is-bad
  validates :full_name, :birth_date, :education, :description, :abilities, 
    presence: true, on: :update

  before_update :set_completed_profile

  def not_canceled_proposals
    proposals.where.not(status: [:canceled_pending, :canceled_approved])
  end

  private
  def set_completed_profile
    self.completed_profile = true
  end
end
