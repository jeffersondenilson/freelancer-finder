class Proposal < ApplicationRecord
  belongs_to :project
  belongs_to :professional

  enum status: { pending: 0, analyzing: 10, approved: 20 }

  validates :message, :value_per_hour, :hours_per_week, :finish_date,
    presence: true

  validates :value_per_hour, numericality: true
  
  validates :hours_per_week, numericality: { only_integer: true, greater_than: 0 }
end
