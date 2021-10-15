class Proposal < ApplicationRecord
  belongs_to :project
  belongs_to :professional

  validates :message, :value_per_hour, :hours_per_week, :finish_date,
    presence: true

  enum status: { pending: 0, analyzing: 10, approved: 20 }
end
