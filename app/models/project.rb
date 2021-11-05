class Project < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id',
    inverse_of: 'projects'
  has_many :proposals, dependent: :destroy

  validates :title, :description, :desired_abilities, :value_per_hour,
            :due_date, presence: true
end
