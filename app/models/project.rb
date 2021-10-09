class Project < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: 'users_id'

  validates :title, :description, :desired_abilities, :value_per_hour, 
    :due_date, :remote, presence: true
end
